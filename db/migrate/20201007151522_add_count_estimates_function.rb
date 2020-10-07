class AddCountEstimatesFunction < ActiveRecord::Migration[6.0]
  def change
    # This function uses the query planner to generate an estimate of rows
    # returned for a given query. If the table is vacuumed regularly, this
    # estimate will be good enough for government work, and it is fast to
    # get it, whereas a real count is very not fast.
    execute <<-ESQL
    CREATE FUNCTION count_estimate(query text) RETURNS integer AS $$
      DECLARE
        rec   record;
        rows  integer;
      BEGIN
        FOR rec IN EXECUTE 'EXPLAIN ' || query LOOP
          rows := substring(rec."QUERY PLAN" FROM ' rows=([[:digit:]]+)');
          EXIT WHEN rows IS NOT NULL;
        END LOOP;
        RETURN rows;
      END;
    $$ LANGUAGE plpgsql VOLATILE STRICT;
    ESQL
  end
end
