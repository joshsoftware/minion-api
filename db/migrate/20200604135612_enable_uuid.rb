# frozen_string_literal: true

# Migration: EnableUuid
class EnableUuid < ActiveRecord::Migration[6.0]
  def self.up
    enable_extension 'uuid-ossp'
    # enable_extension 'pg_crypto'
  end

  def self.down
    disable_extension 'uuid-ossp'
    # disable_extension 'pg_crypto'
  end
end

# Note: If you get errors like this on your dev box:
# PG::UndefinedFile: ERROR:  could not open extension control file
# Install the extension for psql with homebrew: brew install ossp-uuid
