# frozen_string_literal: true

class CreateOrganizations < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'pgcrypto'
    create_table :organizations, id: :uuid do |t|
      t.string :name, null: false
    end
  end
end
