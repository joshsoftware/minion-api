# MINION Dashboard API

This is the API for the MINION dashboard. It primarily communicates with a
PostgreSQL database for most things, but also communicates with LogStash for
whole log retrieval, and ElasticSearch for log search. It also handles authentication
for additional services, like the MINION Agent Service (aka "MAS").

## Helpful Notes

**To exit the server program**, you'll need to hit CTRL+C _twice_. This is
because the main thread might be running Puma, but the other thread is running
the real-time service that the agent and websocket talk to.

**If you see a crash on MacOS with this:**

```
libc++abi.dylib: Pure virtual function called!
[1]    23292 abort      bundle exec puma
```

Chances are something inside an EventMachine block had a Ruby error in it. This
may look like an error with MacOS libraries when multi-threading, but it's more
likely a bug in your code. Poke around with `binding.pry` to find out what's
going on.

### To Start The API _and_ Service:

The API and service are started together. Just run `bundle exec puma`. Done.

### Console

You can use **`rake console`** to interact with the database much like a
Rails console. Anything under lib/models is fair game to work with (though
there's no guarantee on what is and isn't completed at any given time...).

```
$ rake console
Welcome to the Minion application console (based on 'pry').
[1] pry(main)>
```

## API Docs

Note that **we're not doing authentication** right now because this is in the
pitch phase; if and when we get past that, we'll move on to adding it in later.

### GET /commands/all

Gets all commands as one big ass JSON blob back.

```
$ curl -i http://localhost:9292/commands/all
[... lots of output ...]
```

### GET /commands/:id

Returns a specific command where ID is a string (e.g. '004e0036-be86-4a45-b31a-b6179d19db47')

```
curl -i http://localhost:9292/commands/004e0036-be86-4a45-b31a-b6179d19db47
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 547

{"id":"004e0036-be86-4a45-b31a-b6179d19db47","server_id":"abc123","user_id":"asdfasdf","command":"ls /tmp","stderr":[{"output":"\"/somethingthatdoesntexist\": No such file or directory (os error 2)","at":"2020-05-24 23:41:43 +0000"}],"stdout":[{"output":"Permissions Size User Date Modified Name","at":"2020-05-24 23:41:43 +0000"},{"output":"srwxrwxrwx     0 jah  23 May 22:11  .s.PGSQL.5432","at":"2020-05-24 23:41:43 +0000"},{"output":"drwxr-xr-x     - jah  23 May  0:53  7AECB408-B6F3-4E22-ACD9-243D21358609","at":"2020-05-24 23:41:43 +0000"}]}%
```

### POST /commands

Post a request with a response body in JSON to /commands to create a command.

```
$ curl -i http://localhost:9292/commands -X POST -d @test/command.json
HTTP/1.1 201 Created
Content-Type: application/json
Content-Length: 449

{"id":"c72cca08-6163-433e-929a-730f2e92e5e8","server_id":"abc123","user_id":"abcdef","command":"ls /tmp","stderr":[{"output":"\"/somethingthatdoesntexist\": No such file or directory (os error 2)","at":"2020-05-24 23:47:04 +0000"}],"stdout":[{"output":"Permissions Size User Date Modified Name","at":"2020-05-24 23:47:04 +0000"},{"output":"drwxr-xr-x     - jah  23 May  0:53  7AECB408-B6F3-4E22-ACD9-243D21358609","at":"2020-05-24 23:47:04 +0000"}]}
```

## Real-time Service Command Updates

When doing an update to a command (appending a line of text from STDERR, STDOUT)
the agent needs to report in the following format:

```json
{
  "action":"update"
  "command_id":"some id here",
  "device":"stdout",
  "output":"whatever line just happened",
  "at":"Whatever the time was the line was output"
}
```

The service will respond with the following **on success**:

```json
{
  "status":"ok"
}
```

And on failure, it either _won't_ respond (maybe it's down? can't be reached?)
or an error structure as defined by RethinkDB.

## Security Issues

Please email [J. Austin Hughey](https://github.com/jahio) at minion@jah.io.
