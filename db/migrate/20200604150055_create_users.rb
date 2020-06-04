# frozen_string_literal: true

# Migration: CreateUsers
class CreateUsers < ActiveRecord::Migration[6.0]
  def self.up
    create_table :users, id: :uuid do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :password_digest
      t.references :org
    end

    add_index :users, :email
  end

  def self.down
    drop_table :users
  end
end
