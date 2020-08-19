class RemoveIdOnLogs < ActiveRecord::Migration[6.0]
  def change
    execute <<-ESQL
      ALTER TABLE logs DROP CONSTRAINT logs_pkey;
      ALTER TABLE logs DROP COLUMN id;
      ALTER TABLE logs RENAME COLUMN uuid TO id;
      ALTER TABLE logs ADD PRIMARY KEY (id);
    ESQL
  end
end
