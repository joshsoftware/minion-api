class ReconfigureTelemetriesIndexes < ActiveRecord::Migration[6.0]
  def change
    execute <<-ESQL
    DROP INDEX created_at_idx;
    DROP INDEX data_idx;
    CREATE INDEX telemetries_data_idx ON telemetries USING GIN(data);
    CREATE INDEX telemetries_create_at_brin_idx ON telemetries USING BRIN(created_at);
    CREATE INDEX telemetries_load_avg_idx ON telemetries USING BTREE(server_id, created_at, (data ? 'load_avg'));
    ESQL
  end
end
