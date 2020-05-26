# frozen_string_literal: true

# init.rb
# Initialization for Minion's API/TCP service

require 'connection_pool'
require 'dry-struct'
require 'em-websocket'
require 'eventmachine'
require 'fileutils'
require 'grape'
require 'grape_logging'
require 'json'
require 'jwt'
require 'pp'
require 'pry' # yes, even in prod, for the console feature
require 'puma'
require 'rack'
require 'rethinkdb'

# Check for necessary database connection variables and exit if not present
unless ENV['RETHINKDB_HOST'] && ENV['RETHINKDB_HOST'] != ''
  if %w[production staging].include? ENV['RUNTIME_ENV']
    puts "No RETHINKDB_HOST environment variable, cannot continue."
    exit(1)
  end
  ENV['RETHINKDB_HOST'] = 'localhost' # dev/test fallback
end

ENV['RUNTIME_ENV'] = (ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development')

# Grab all the stuff under the following directories:
DIRS = ['lib', 'api', 'service'].freeze

DIRS.each do |dir|
  Dir.glob(File.join(FileUtils.pwd, dir, '**', '*.rb')).each { |f| require f }
end

APPLICATION_ROOT = File.expand_path(File.dirname(__FILE__))

# Create a connection pool for RethinkDB so multiple threads can access
# that pool rather easily.
$pool = ConnectionPool.new(size: 10, timeout: 5) {
  RethinkDB::RQL.new.connect(host: ENV['RETHINKDB_HOST'], port: 28015, db:'minion')
}
