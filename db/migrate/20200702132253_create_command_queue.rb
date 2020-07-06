class CreateCommandQueue < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'pgcrypto'
    create_table :command_queues, id: :uuid do |t|
      t.uuid :command_id, null: false
      t.timestamps
      t.index :created_at
    end
  end
end
