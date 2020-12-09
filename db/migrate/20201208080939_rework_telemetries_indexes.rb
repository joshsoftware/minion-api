class ReworkTelemetriesIndexes < ActiveRecord::Migration[6.0]
  def change
    execute <<-ESQL
    CREATE INDEX telemetries_server_id_data_key_idx ON telemetries USING BTREE(server_id, data_key);
    ESQL
  end
end

