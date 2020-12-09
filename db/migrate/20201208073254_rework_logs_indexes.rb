class ReworkLogsIndexes < ActiveRecord::Migration[6.0]
  def change
    execute <<-ESQL
    DROP INDEX index_logs_on_service;
    DROP INDEX logs_server_id_idx;
    CREATE INDEX logs_server_id_service_idx ON logs USING BTREE(server_id, service);
    ESQL
  end
end

