class CreateServersCommands < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'pgcrypto'
    create_table :servers_commands, id: :uuid do |t|
      t.uuid :server_id, null: false
      t.uuid :command_id, null: false
      t.uuid :response_id
      t.timestamp :dispatched_at
      t.timestamp :response_at
      t.timestamps
      t.index :server_id
      t.index :command_id
      t.index :response_id
    end
  end
end
