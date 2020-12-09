class AddJsonbXTimestamp < ActiveRecord::Migration[6.0]
  def change
    execute <<-ESQL
    CREATE TYPE
      jsonb_x_timestamp AS
        (
          data JSONB,
          created_at TIMESTAMP WITHOUT TIME ZONE
        )
    ESQL
  end
end
