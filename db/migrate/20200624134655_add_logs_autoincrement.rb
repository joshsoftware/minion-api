class AddLogsAutoincrement < ActiveRecord::Migration[6.0]
  def self.up
    execute <<-SQL
     CREATE SEQUENCE logs_id_seq START 1;
     ALTER TABLE logs ALTER COLUMN id SET DEFAULT nextval('logs_id_seq');
    SQL
  end


  def self.down
    execute <<-SQL
      DROP SEQUENCE logs_id_seq;
    SQL
  end
end
