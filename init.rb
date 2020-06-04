# frozen_string_literal: true

require('active_model')
require('active_record')
require('bcrypt')
require('grape')
require('pry') # for the console

# Grab all the stuff under the following directories:
DIRS = %w[lib api models].freeze

DIRS.each do |dir|
  Dir.glob(File.join(FileUtils.pwd, dir, '**', '*.rb')).sort.each { |f| require f }
end

APP_ROOT = File.expand_path(__dir__)

RUNTIME_ENV ||= (ENV['RACK_ENV'] || ENV['RUNTIME_ENV'] || 'development')

DB_CONFIG = YAML.safe_load(File.open(File.join(APP_ROOT, 'config', 'database.yml')))[RUNTIME_ENV]

ActiveRecord::Base.establish_connection(DB_CONFIG)
