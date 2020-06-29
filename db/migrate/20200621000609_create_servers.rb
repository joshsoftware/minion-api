# frozen_string_literal: true

class CreateServers < ActiveRecord::Migration[6.0]
  def change
    create_table :servers, id: :uuid do |t|
      t.string :aliases, array: true
      t.inet :addresses, array: true
    end
  end
end
