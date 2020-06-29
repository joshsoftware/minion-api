class AddTelemetriesAutoincrement < ActiveRecord::Migration[6.0]
  def self.up
    execute <<-SQL
     CREATE SEQUENCE telemetries_id_seq START 1;
     ALTER TABLE telemetries ALTER COLUMN id SET DEFAULT nextval('telemetries_id_seq');
    SQL
  end

  def self.down
    execute <<-SQL
      DROP SEQUENCE telemetries_id_seq;
    SQL
  end
end
