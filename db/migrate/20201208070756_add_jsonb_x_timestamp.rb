class AddJsonbXTimestamp < ActiveRecord::Migration[6.0]
  def change
    # This function uses the query planner to generate an estimate of rows
    # returned for a given query. If the table is vacuumed regularly, this
    # estimate will be good enough for government work, and it is fast to
    # get it, whereas a real count is very not fast.
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
