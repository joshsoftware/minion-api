class CreateCommands < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'pgcrypto'
    create_table :commands, id: :uuid do |t|
      t.string :argv, array: true
    end
  end
end
