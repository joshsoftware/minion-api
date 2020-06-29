class ChangeDataOnTelemetries < ActiveRecord::Migration[6.0]
  def change
    remove_column :telemetries, :data
    add_column :telemetries, :data, :jsonb
  end
end
