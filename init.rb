# init.rb
# Initialization for Minion's API/TCP service

require 'fileutils'
require 'rethinkdb'
require 'em-websocket'
require 'json'
require 'jwt'
require 'pry' # yes, even in prod, for the console feature

# Check for necessary database connection variables and exit if not present
unless ENV['RETHINKDB_HOST'] && ENV['RETHINKDB_HOST'] != ''
  if ['production', 'staging'].include? ENV['RUNTIME_ENV']
    puts "No RETHINKDB_HOST environment variable, cannot continue."
    exit(1)
  end
  ENV['RETHINKDB_HOST'] = 'localhost' # dev/test fallback
end

ENV['RUNTIME_ENV'] ||= (ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development')

# Grab all the stuff under the following directories:
DIRS = ['lib', 'api', 'service']

DIRS.each do |dir|
  Dir.glob(File.join(FileUtils.pwd, dir, '**', '*.rb')).each { |f| require f }
end

# Bring in the primary application start points
require_relative File.join('.', 'api')
require_relative File.join('.', 'service')

APPLICATION_ROOT = File.expand_path(File.dirname(__FILE__))
