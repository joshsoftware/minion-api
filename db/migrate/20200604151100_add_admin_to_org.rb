# frozen_string_literal: true

# Migration: AddAdminToOrg
class AddAdminToOrg < ActiveRecord::Migration[6.0]
  def self.up
    add_column :orgs, :admin_id, :uuid, references: 'orgs'
    add_index :orgs, :admin_id
  end

  def self.down
    remove_column :orgs, :admin_id
  end
end
