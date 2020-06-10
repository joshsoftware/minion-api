#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rethinkdb'
require 'json'

include RethinkDB::Shortcuts

conn = r.connect(:host => 'localhost', :port => 28015)

# Create a command in the rethinkdb consonle and use that UUID here (replace below)

r.db('minion').table('commands').get('914501cb-3071-4598-a0ab-6c876c949b1d').changes().run(conn).each { |change| p change }

# More info:
# https://rethinkdb.com/docs/changefeeds/ruby/