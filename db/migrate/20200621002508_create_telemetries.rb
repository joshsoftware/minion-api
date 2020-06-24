class CreateTelemetries < ActiveRecord::Migration[6.0]
  def change
    create_table :telemetries, primary_key: [:id, :server_id] do |t|
      t.bigint :id, null: false
      t.uuid :server_id, null: false
      t.uuid :uuid, null: false
      t.string :data, null: false, array: true
    end
  end
end
