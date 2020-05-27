#!/usr/bin/env ruby
# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'init')

$connections = Set.new

Thread.new {
  run lambda {|env|
    Async::WebSocket::Adapters::Rack.open(env, protocols: ['ws']) do |connection|
      $connections << connection

      while message = connection.read
        $connections.each do |connection|
binding.pry
          connection.write(message)
          connection.flush
        end
      end
    ensure
      $connections.delete(connection)
    end or [200, {}, ["Hello World"]]
  }
}.join
