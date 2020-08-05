class AddTsvToLogs < ActiveRecord::Migration[6.0]
  def up
    execute <<-ESQL
    ALTER TABLE logs ADD tsv tsvector;

    CREATE FUNCTION logs_tsv_trigger() RETURNS trigger AS $$  
      begin  
        new.tsv :=
          setweight(to_tsvector('english', new.service), 'A') ||
          setweight(to_tsvector('english', new.msg), 'B');
        return new;
      end  
    $$ LANGUAGE plpgsql;

    CREATE TRIGGER update_logs_tsvector BEFORE INSERT OR UPDATE
    ON logs
    FOR EACH ROW EXECUTE PROCEDURE logs_tsv_trigger();

    CREATE INDEX logs_tsv_idx ON logs USING GIN(tsv);
    CREATE INDEX logs_server_id_idx ON logs USING BTREE(server_id);
    CREATE INDEX logs_created_at_idx ON logs USING BTREE(created_at);

    ESQL
  end

  def down
    execute <<-ESQL
    DROP TRIGGER update_logs_tsvector;

    DROP FUNCTION logs_tsv_trigger;

    ALTER TABLE logs DROP COLUMN tsv;
    ESQL
  end
end
