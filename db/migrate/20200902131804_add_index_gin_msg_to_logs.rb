class AddIndexGinMsgToLogs < ActiveRecord::Migration[6.0]
  def change
    execute <<-ESQL
    CREATE EXTENSION pg_trgm;
    CREATE INDEX logs_msg_gin ON logs USING GIN(msg gin_trgm_ops);
    ESQL
  end
end
