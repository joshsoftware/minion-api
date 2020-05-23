# MINION Dashboard API

This is the API for the MINION dashboard. It primarily communicates with a
PostgreSQL database for most things, but also communicates with LogStash for
whole log retrieval, and ElasticSearch for log search. It also handles authentication
for additional services, like the MINION Agent Service (aka "MAS").

## Security Issues

Please email [J. Austin Hughey](https://github.com/jahio) at minion@jah.io.
