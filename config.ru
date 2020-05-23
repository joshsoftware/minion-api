#!/usr/bin/env ruby

require File.join('.', 'api')
require File.join('.', 'service')

unless ['production', 'staging'].include? (ENV['RUNTIME_ENV'] || ENV['RACK_ENV'])
  require 'pry'
end

Thread.new {
  Sinatra::Application.set :port => 9000
  run Sinatra::Application
}.join

Thread.new {
  Minion::Service.start
}
