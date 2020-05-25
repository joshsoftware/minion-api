#!/usr/bin/env ruby

require File.join('.', 'init')

Thread.new {
  run Minion::API
}.join

Thread.new {
  Minion::Service.start
}
