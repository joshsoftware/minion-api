# MINION Dashboard API

This is the API for the MINION dashboard. It primarily communicates with a
PostgreSQL database for most things, but also communicates with LogStash for
whole log retrieval, and ElasticSearch for log search. It also handles authentication
for additional services, like the MINION Agent Service (aka "MAS").

## Helpful Notes

**To exit the server program**, you'll need to hit CTRL+C _twice_. This is
because the main thread might be running Puma, but the other thread is running
the real-time service that the agent and websocket talk to.

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

## Security Issues

Please email [J. Austin Hughey](https://github.com/jahio) at minion@jah.io.
