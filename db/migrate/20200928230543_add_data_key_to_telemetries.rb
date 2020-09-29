class AddDataKeyToTelemetries < ActiveRecord::Migration[6.0]
  def change
    execute <<-ESQL
    DROP INDEX telemetries_load_avg_idx;
    ALTER TABLE telemetries ADD COLUMN data_key TEXT NOT NULL DEFAULT '';
    --
    CREATE OR REPLACE FUNCTION telemetries_update_data_key()
      RETURNS TRIGGER 
      LANGUAGE PLPGSQL
      AS
    $$
    DECLARE
      myrec character varying(255);
    BEGIN
      SELECT
        (ARRAY_AGG(key.label))[1] INTO myrec
      FROM
        (
          SELECT
            JSONB_OBJECT_KEYS
              (
                CASE WHEN (JSONB_TYPEOF(NEW.data) = 'object')
                  THEN NEW.data
                  ELSE JSONB_BUILD_OBJECT(NEW.data->>0, 1)
                END
              ) AS label
        ) key;
      NEW.data_key = myrec;
      RETURN NEW;
    END;
    $$;
    --
    CREATE TRIGGER
      telemetries_update_data_key_trigger
    BEFORE
      INSERT OR UPDATE OF DATA
      ON telemetries
    FOR EACH ROW
    EXECUTE PROCEDURE
      telemetries_update_data_key();
    --
    CREATE INDEX
      telemetries_kitchen_sink_idx ON telemetries USING BTREE(server_id, created_at, data_key);
    ESQL
  end
end
