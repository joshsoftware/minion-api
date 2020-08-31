module MinionAPI
  struct Telemetry
    include JSON::Serializable

    def self.get_data(uuid : String, criteria : Array(Hash(String, String))?, limit = 500)
      data = {} of String => Array({JSON::Any, Int64})

      where_by_date = MinionAPI::Helpers.where_by_date("created_at", criteria)
      where_by_json_key = MinionAPI::Helpers.where_by_json_key("data", "type", criteria)

      MinionAPI::Helpers.list_of_where_by_json_key("data", "type", criteria).each do |key_sql_pair|
        key, key_sql = key_sql_pair

        sql = <<-ESQL
        SELECT
          COUNT(*)
        FROM
          telemetries
        WHERE
          server_id = $1
          #{where_by_date}
          #{key_sql}
        ESQL
  
        count = 0_64
        DBH.using_connection do |conn|
          count = conn.query_one(sql, uuid, as: {Int64})
        end
  
        row_modulo = (count / limit).to_i # TODO: Make this use the max lines instead
        row_modulo = 1 if row_modulo == 0

        sql = <<-ESQL
        SELECT
          t.*
        FROM (
          SELECT
            data,
            created_at,
            row_number()
              OVER (ORDER BY created_at ASC)
              AS row
          FROM
            telemetries
          WHERE
            server_id = $1
            #{where_by_date}
            #{key_sql}
          ) 
        AS t
        WHERE
          t.row %#{row_modulo} = 0
        ESQL

        query_data = [] of Tuple(JSON::Any, Int64)
        debug!(sql)
        DBH.using_connection do |conn|
          conn.query_each(sql, uuid) do |rs|
            query_data << {
              rs.read(JSON::Any),
              rs.read(Time).to_unix_ms,
            }
          end
        end

        data[key] = query_data
      end

      data
    rescue ex
      debug!(ex)
      data
    end

    # TODO: It would be better, when we have proper ackground job support, if
    # there were a background job that would, on a repeating basis, determine
    # the query keys available for each customer, and would put that data into
    # a dedicated table, thus eliminating the dynamic querying of this data.
    PDK_SQL = <<-ESQL
    SELECT
      DISTINCT(ky.keys)
    FROM
     (
       SELECT
         jsonb_path_query(data,'$[0]') AS keys
      FROM
        telemetries
      WHERE
        jsonb_typeof(data) = 'array' AND
        server_id IN(SERVERS)
      ORDER BY
        created_at DESC
      LIMIT 10000
      ) AS ky
    ESQL

    # This determines which query keys are available for accessing data that
    # is stored via tuples of key and value, as an array.
    def self.get_primary_data_keys(servers)
      data_keys = [] of String
      arg_n = 0
      pdk_sql = PDK_SQL.gsub(/SERVERS/) do
        servers.map { |s| arg_n += 1; "$#{arg_n}" }.join(",")
      end
      debug!(pdk_sql)
      DBH.using_connection do |conn|
        conn.query_each(pdk_sql, args: servers) do |rs|
          data_keys << rs.read(JSON::Any).as_s
        end
      end

      data_keys
    end

    COUNT_SQL = <<-ESQL
    SELECT
      count(*)
    FROM
      telemetries
    ESQL

    def self.count
      DBH.using_connection do |conn|
        conn.query_one(COUNT_SQL, as: {Int64})
      end
    rescue
      {nil}
    end

    property uuid : String?
    property server_id : String?
    property data : JSON::Any?
    property created_at : Time?
    property updated_at : Time?

    def initialize(@uuid : String)
      @name, @created_at = Organization.get_data(@uuid)
    end

    def to_h
      {
        "uuid"       => @uuid,
        "server_id"  => @server_id,
        "data"       => @data,
        "created_at" => @created_at,
        "updated_at" => @updated_at,
      }
    end
  end
end
