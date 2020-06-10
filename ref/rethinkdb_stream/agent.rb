#!/usr/bin/env ruby
# frozen_string_literal: true

# This is a mock agent. It simulates the idea of appending STDOUT output
# to a given command. Create that command in your RethinkDB console first
# on localhost, then specify its UUID here.

uuid = '914501cb-3071-4598-a0ab-6c876c949b1d'

require 'rethinkdb'
require 'json'

include RethinkDB::Shortcuts

conn = r.connect(host: 'localhost', port: 28015)

r.db('minion').table('commands').get(uuid).update { |cmd|
  { stdout: cmd['stdout'].append('Hello World!') }
}.run(conn)
