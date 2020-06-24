# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :name
      t.string :email
      t.string :mobile_number
      t.string :password_digest
      t.belongs_to :organization, type: :uuid, null: false
      t.references :role
      t.timestamps
    end
    add_index :users, :email
  end
end
