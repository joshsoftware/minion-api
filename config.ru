#!/usr/bin/env ruby

require File.join('.', 'api')
require File.join('.', 'service')

Thread.new {
  Sinatra::Application.set :port => 9000
  run Sinatra::Application
}.join

Thread.new {
  Minion::Service.start
}
