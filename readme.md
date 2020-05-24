# MINION Dashboard API

This is the API for the MINION dashboard. It primarily communicates with a
PostgreSQL database for most things, but also communicates with LogStash for
whole log retrieval, and ElasticSearch for log search. It also handles authentication
for additional services, like the MINION Agent Service (aka "MAS").

## Helpful Stuff

```
$ rake console
Welcome to the Minion application console (based on 'pry').
[1] pry(main)>
```

You can use **`rake console`** to interact with the database much like a
Rails console. Anything under lib/models is fair game to work with (though
there's no guarantee on what is and isn't completed at any given time...).

## Security Issues

Please email [J. Austin Hughey](https://github.com/jahio) at minion@jah.io.
