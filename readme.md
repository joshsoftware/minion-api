# Minion API Spec

The Minion architecture will consist of several services and parts, but one of
the most critical is the HTTP API. Laid out below are the main functions that
API needs to have, along with a description of each, example input and example
expected output.

I'm trying to put down "Authentication Required" where it's necessary, but if
I've missed it and it seems like it's something that's needed, use your best
judgement and add it. That goes for all of this - use your best judgement and
if anything's unclear, **feel free to get in touch with me!**

- [J. Austin Hughey](mailto:j.austin.hughey@joshsoftware.com)

## API FUNCTIONS

We'll put all API paths under `/api/v1/` to start with rather than making it
a necessary header. This is just easier to do.

## Authentication Overview

Authentication for this app will be via [JWT](http://jwt.io). A user presents
their email and password, and if valid, they'll be issued a JSON Web Token,
cryptographically signed by this app, that will then be saved by the front-end
and presented in an HTTP header on each subsequent request where authentication
is required.

In short, conduct the login as explained below and you'll get a response back
with a header of `Authorization` and a token value for the value of that header.
Every request from then on needs to include that token in its own
`Authorization` header as follows:

```
Authorization: bearer <token goes here>
```

### /users

+ Create a user
+ Login as that user
+ Get information for yourself (current user bearing JWT)
+ Logout (blacklist the token)

#### POST /users

Given a `POST` to `/users`, create a new user. Sample input POST body:

```json
{
  "name":"J. Austin Hughey",
  "email":"jah@jah.io",
  "password":"A really secure password",
  "phone":"+1 (512) 123-4567"
}
```

Sample expected returned user information:

```json
{
  "user_id":"<some uuid here>",
  "email":"jah@jah.io",
  "name":"J. Austin Hughey",
  "phone":"+1 (512) 123-4567"
}
```

When creating a new user, create an organization as well that's named after
their name, with a blank website and that new user specified as the admin for
that organization. This is all placeholder stuff for future iterations but for
now, that's good enough. Just make sure **every user belongs to their own
organization** when they've signed up.

#### GET /users/me

**AUTHENTICATION REQUIRED**

Input: just the JWT token that was issued in authentication

Output (example):

```json
{
  "name":"J. Austin Hughey",
  "email":"jah@jah.io",
  "password":"A really secure password",
  "phone":"+1 (512) 123-4567",
  "organization": {
    "name":"Org Name",
    "website":"http://www.example.com/",
    "admin_id":"<some uuid representing an admin user for this org>"
  }
}
```

### /logout

#### GET /logout

**AUTHENTICATION REQUIRED**

Given an existing token (`Authorization` header), log the person out by adding
that token to a blacklisted tokens table. Then redirect them to the login page.

### /login

#### POST /login

No auth required, only a valid user. Given a POST body of JSON as follows,
ensure the user isn't deactivated (`WHERE deactivated_at IS NULL`) and if found,
authenticate the user with the password provided.

Example request body:

```json
{
  "email":"me@example.com",
  "password":"abc123"
}
```

If the login is valid, return basic user info as seen in `GET /users/me` along
with an Authorization header as follows:

```
Authorization: bearer <JWT goes here>
```

JWT stands for JSON Web Token. It needs to be generated on each valid login, and
then verified each time the user presents it with each request. If the signature
turns out to be valid, then we issued it and the user's request is valid.

Read more at jwt.io.

### /servers

The point of this section of the app is to manage and retrieve information
for each server managed by Minion. We start by registering a given server, which
will then give that server a name in the dashboard and allow us to send new
configuration data out to it via the stream server (different part of the
architecture). Once we know about it, we can then send it commands and review
logs for that server via our logging interface.

A server belongs not to a user, but to an _organization_. So when a minion agent
registers a new server, it'll do so by reporting an organization ID (which will
be our database UUID representing an organization). When the API receives that
registration, it'll generate a name for the server at random (duplication is
OK here, for now anyway) and assign it to that server in our database/dashboard.

#### GET /servers

**AUTHENTICATION REQUIRED**

Returns a list of all servers (for now; we'll "paginate" that later), ordered
by registration date (e.g. `created_at`) that belong to the user's organization.

#### POST /servers

Server registration as described above. A Minion agent will register a server
by performing a POST request with a body similar to the following example:

```json
{
  "organization_id":"<some uuuid here>"
}
```

From our perspective, a server is a server is a server. We don't care what it's
doing under the hood, that's up to the operator. We'll add custom tagging
support in a future release.

When the server is registered (created in the database), the API should respond
with something like:

```json
{
  "server_id":"<server's uuid here>",
  "organization_id":"<same uuid as before for the org>",
  "name":"Dancing Catfish (a name made up by the app, see Server.name)",
  "config": {
    "todo":"For now return an empty object, but we'll define more formal configuration later"
  }
}
```
