class CreateCommandResponses < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'pgcrypto'
    create_table :command_responses, id: :uuid do |t|
      t.string :response, null: false, array: true
      t.string :hash, null: false
      t.timestamps
      t.index :hash, unique: true
    end
  end
end
