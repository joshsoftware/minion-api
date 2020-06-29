class ChangeTelemetriesPrimaryKey < ActiveRecord::Migration[6.0]
  def change
    execute <<-SQL
      ALTER TABLE telemetries ALTER COLUMN id DROP DEFAULT;
      DROP SEQUENCE telemetries_id_seq;
      ALTER TABLE telemetries DROP CONSTRAINT telemetries_pkey;
      ALTER TABLE telemetries ADD PRIMARY KEY (server_id, uuid);
    SQL

    remove_column :telemetries, :id
  end
end
