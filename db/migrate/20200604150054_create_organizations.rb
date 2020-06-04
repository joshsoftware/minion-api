# frozen_string_literal: true

# Migration: CreateOrganizations
class CreateOrganizations < ActiveRecord::Migration[6.0]
  def self.up
    create_table :orgs, id: :uuid do |t|
      t.string :name
      t.string :website
    end
  end

  def self.down
  end
end
