#!/usr/bin/env ruby

require File.join('.', 'init')

Thread.new {
  Minion::Service.start
}

run Minion::API
