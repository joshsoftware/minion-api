#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative(File.join('.', 'init'))
use ActiveRecord::ConnectionAdapters::ConnectionManagement
run Minion::API
