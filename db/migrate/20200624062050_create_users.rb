# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :name
      t.string :email
      t.string :mobile_number, index: true
      t.string :password_digest
      t.string :role, index: true
      t.timestamps
    end
    add_index :users, :email
  end
end
