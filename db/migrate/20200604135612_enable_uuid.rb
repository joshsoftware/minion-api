# frozen_string_literal: true

# Migration: EnableUuid
class EnableUuid < ActiveRecord::Migration[6.0]
  def self.up
    enable_extension 'uuid-ossp'
    enable_extension 'pgcrypto'
  end

  def self.down
    disable_extension 'uuid-ossp'
    disable_extension 'pgcrypto'
  end
end
