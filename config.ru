#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative(File.join('.', 'init'))

use ActionDispatch::Executor, ActiveSupport::Executor
ActiveRecord::QueryCache.install_executor_hooks

run Minion::API
