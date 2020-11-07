# Minion API Server

This is the Minion API Server. It is implemented using the Athena framework,
which provides a rich developer experience for writing high performance API
servers with a small RAM footprint. The Crystal/Athena API server takes a
small fraction of the RAM that the RAILS one takes.

The migrations for the database are currently Rails/ActiveRecord managed, but
are the only thing out of the original API spike that is actively used.

## API Implementation

> No plan of operations reaches with any certainty beyond the first encounter with the enemy's main force.
> -- Helmuth von Multke

The current API started life inspired by the Rails version, but mutated organically as actual features of the API started being required to deliver functionality to the UI.

The code implements a set of controllers that define the URLs and the HTTP verbs that it will act upon, and a set of models which define the interface to the database, and which represent data from the database, as necessary.

The implementation does not use an ORM in the model layer both because it was simple and direct to just use SQL as needed, and because the API layer often interacts with a large volume of data, such as when it is accessing telemetry data for charting, or delivering log data, and there is no functional benefit to using an ORM in those cases.

## Contributing

1. Fork it (<https://github.com/joshsoftware/minion-api/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Kirk Haines](https://github.com/wyhaines)
