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

## Dev Box Setup Notes

Assumes you're on MacOS using Homebrew. Not updating Ruby or Rails because modern updates to those have broken a lot of stuff, and eventually we'd like to eject ActiveRecord and Ruby entirely anyway in favor of 100% Crystal implementation, so for now, just install the versions of Ruby and Rails that are mentioned in the `.ruby-version` and `Gemfile` respectively and go from there. It's not going to matter at runtime anyway since this is compiled code.

```
brew install postgresql@15 libpq && brew link postgresql@15 && brew services start postgresql@15
psql -d postgres
CREATE USER dev WITH ENCRYPTED PASSWORD 'dev';
CREATE DATABASE "minion-development" OWNER dev;
\q
bundle install
bundle exec rake db:migrate # cross your fingers - see notes below about weird mimemagic xml
brew install wget # shards apparently has a hard reliance on this
shards install

```

### GOTCHA: mimemagic can't find some crazy xml file?

If you're running into some ridiculous complaining about mimemagic not being able to find an xml file, grab this file from freedesktop.org:

https://cgit.freedesktop.org/xdg/shared-mime-info/plain/freedesktop.org.xml.in?h=Release-1-9

Now dump it in the following directory and modify permissions accordingly. You'll need to be root to do this.

```
mkdir -p /usr/local/share/mime/packages
mv /path/to/wherever/you/downloaded/that/god/awful/xml/from/hell.xml /usr/local/share/mime/packages/freedesktop.org.xml
chmod -R 655 /usr/local/share/mime
```

Yes, oddly enough the execute bit on the directory, recursively, is required on MacOS in order to access read permissions on the parent directory to even get at the XML file itself. Weird. Shouldn't be necessary but when I tried 644 (R/W, R, R) my normal (non-root) user couldn't even read what was _in_ the `mime` directory, let alone all the stuff underneath it. Changing that to 655 immediately rectified the problem. Arcane mysteries of APFS, maybe? Who knows.

## Contributing

1. Fork it (<https://github.com/joshsoftware/minion-api/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Kirk Haines](https://github.com/wyhaines)
