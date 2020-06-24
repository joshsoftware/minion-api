class CreateLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :logs, primary_key: [:id, :server_id] do |t|
      t.bigint :id, null: false
      t.uuid :server_id, null: false
      t.uuid :uuid, null: false
      t.string :service, null: false
      t.string :msg, null: false
    end
  end
end
