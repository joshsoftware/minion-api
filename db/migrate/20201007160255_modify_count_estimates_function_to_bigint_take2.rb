class ModifyCountEstimatesFunctionToBigintTake2 < ActiveRecord::Migration[6.0]
  def change
    execute <<-ESQL
    DROP FUNCTION count_estimate;
    -- Recreate it using a bigint as the return type.
    CREATE FUNCTION count_estimate(query text) RETURNS bigint AS $$
      DECLARE
        rec   record;
        rows  bigint;
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
