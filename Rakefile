#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative(File.join('.', 'init'))

desc 'Application Console'
task :console do
  puts 'Welcome to the Minion API console, powered by Pry. Type "exit" to exit.'
  Pry.start
end

namespace :db do
  desc 'Creates the database'
  task :create do
    ActiveRecord::Base.establish_connection(DB_CONFIG.merge({'database':'postgres', 'schema_search_path':'public'}))
    ActiveRecord::Base.connection.create_database(DB_CONFIG['database'])
    puts "Created database: #{DB_CONFIG['database']}"
  end

  desc 'Drops the database'
  task :drop do
    ActiveRecord::Base.establish_connection(DB_CONFIG.merge({'database':'postgres', 'schema_search_path':'public'}))
    ActiveRecord::Base.connection.drop_database(DB_CONFIG['database'])
    puts "Dropped database: #{DB_CONFIG['database']}"
  end

  desc 'Migrate the database'
  task :migrate do
    ActiveRecord::Base.connection_pool.with_connection do |connection|
      connection.migration_context.migrate
    end
    Rake::Task['db:schema'].invoke
    puts 'Database migrated.'
  end

  desc 'Create db/schema.rb file that is portable against database supported by ActiveRecord'
  task :schema do
    require 'active_record/schema_dumper'
    filename = File.join(APP_ROOT, 'db', 'schema.rb')
    File.open(filename, 'w:utf-8') do |f|
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, f)
    end
  end

  desc 'Resets the database'
  task :reset do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
  end

end

namespace :g do # short for "generate"
  desc 'Creates a db migration: rake g:migration your_migration_name'
  task :migration do
    name = ARGV[1] || raise('You need to specify a name: rake g:migration NAME_GOES_HERE')
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    path = File.join(APP_ROOT, 'db', 'migrate', "#{timestamp}_#{name}.rb")
    migration_class = name.split('_').map(&:capitalize).join
    File.open(path, 'w') do |f|
      f.write <<~END_OF_MIGRATION
        # frozen_string_literal: true

        # Migration: #{migration_class}
        class #{migration_class} < ActiveRecord::Migration[6.0]
          def self.up
          end

          def self.down
          end
        end
      END_OF_MIGRATION
      puts "Migration #{path} created."
      abort # prevents trying to run the migration name as another rake task
    end
  end
end
