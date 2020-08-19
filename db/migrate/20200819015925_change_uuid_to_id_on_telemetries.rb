class ChangeUuidToIdOnTelemetries < ActiveRecord::Migration[6.0]
  def change
    execute <<-ESQL
    ALTER TABLE telemetries RENAME COLUMN uuid TO id
    ESQL
  end
end
