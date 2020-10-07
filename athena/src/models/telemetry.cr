module MinionAPI
  struct Telemetry
    include JSON::Serializable

    def self.get_data(uuid : String, criteria : Array(Hash(String, String))?, limit = 500)
      debug!("get_data")
      data = {} of String => Array({JSON::Any, Int64})

      where_by_date = MinionAPI::Helpers.where_by_date("created_at", criteria)
      where_by_json_key = MinionAPI::Helpers.where_by_json_key("data", "type", criteria)

      # start = Time.parse(start_timestamp, ,"%Y-%m-%d %H:%M:%S", Time::Location::UTC)
      # finish = Time.parse(finish_timestamp, ,"%Y-%m-%d %H:%M:%S", Time::Location::UTC)
      # seconds_per_point = (finish - start).to_i / points

      MinionAPI::Helpers.list_of_where_by_data_key("type", criteria).each do |key_sql_pair|
        key, key_sql = key_sql_pair

        sql = <<-ESQL
        SELECT
          MIN(created_at),
          MAX(created_at)
        FROM
          telemetries
        WHERE
          server_id = $1
          #{where_by_date}
          #{key_sql}
        ESQL

        from_date : Time? = nil
        to_date : Time? = nil
        DBH.using_connection do |conn|
          conn.query_each(sql, uuid) do |rs|
            from_date = rs.read(Time)
            to_date = rs.read(Time)
          end
        end

        interval = "#{(to_date.not_nil! - from_date.not_nil!).to_f / limit} seconds"

        sql = <<-ESQL
        SELECT
          (row).data,
          (row).created_at
        FROM
          (
            SELECT
              (
                SELECT
                  (
                    t.data,
                    t.created_at
                  )::jsonb_x_timestamp as row
                FROM
                  telemetries t
                WHERE
                  server_id = $1
                  #{key_sql}
                  AND t.created_at >= s.target
                  AND t.created_at <=
                    (s.target + INTERVAL '#{interval}')
                  LIMIT 1
                )
              FROM
                (
                  SELECT
                    target
                  FROM
                    GENERATE_SERIES(
                      $2,
                      $3,
                      INTERVAL '#{interval}'
                    ) target
                ) s
          ) response
        ESQL

        query_data = [] of Tuple(JSON::Any, Int64)
        DBH.using_connection do |conn|
          conn.query_each(sql, uuid, from_date.not_nil!.to_s("%Y-%m-%d %H:%M:%S"), to_date.not_nil!.to_s("%Y-%m-%d %H:%M:%S")) do |rs|
            js = rs.read(JSON::Any?)
            ts = rs.read(Time?)
            next if js.nil? || ts.nil?

            query_data << {
              js.not_nil!,
              ts.not_nil!.to_unix_ms,
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
        server_id IN(SERVERS) AND
        created_at > (NOW() - INTERVAL '1 day')
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

    ACCURATE_COUNT_SQL = <<-ESQL
    SELECT
      count(*)
    FROM
      telemetries
    ESQL

    FAST_COUNT_SQL = <<-ESQL
    SELECT
      count_estimate('SELECT 1 FROM TELEMETRIES')
    ESQL

    def self.count(accurate = false)
      DBH.using_connection do |conn|
        unless accurate
          conn.query_one(FAST_COUNT_SQL, as: {Int64})
        else
          conn.query_one(ACCURATE_COUNT_SQL, as: {Int64})
        end
      end
    rescue ex : Exception
      debug!(ex)
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
