class AddIndexToTelemetries < ActiveRecord::Migration[6.0]
  def change
    execute <<-ESQL
    CREATE INDEX data_idx ON telemetries USING GIN(data);
    CREATE INDEX created_at_idx ON telemetries USING BTREE(created_at);
    ESQL
  end
end
