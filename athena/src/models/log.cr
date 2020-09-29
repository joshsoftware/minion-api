module MinionAPI
  struct Log
    include JSON::Serializable

    # This query is faster than the more obvious:
    # SELECT DISTINCT(service) FROM logs WHERE server_id IN (...);
    # particularly as the count of rows increases.

    GET_DISTINCT_SERVICES = <<-ESQL
    WITH RECURSIVE t AS (
      (
        SELECT
          service
        FROM
          logs
        WHERE
          server_id IN(SERVERS)
        ORDER BY
          service
        LIMIT 1
      )
      UNION ALL
      SELECT
        (
          SELECT
            service
          FROM
            logs
          WHERE
            service > t.service AND
            server_id IN(SERVERS)
          ORDER BY
            service
          LIMIT 1
        )
      FROM
        t
      WHERE
        t.service IS NOT NULL
    )
    SELECT service FROM t WHERE service IS NOT NULL
    ESQL

    def self.get_unique_services(servers)
      services = [] of String
      arg_n = 0
      service_sql = GET_DISTINCT_SERVICES.gsub(/SERVERS/) do
        servers.map { |s| arg_n += 1; "$#{arg_n}" }.join(",")
      end
      debug!(service_sql)
      DBH.using_connection do |conn|
        conn.query_each(service_sql, args: servers.concat(servers)) do |rs|
          services << rs.read(String)
        end
      end

      services
    end

    GET_QUERY = <<-ESQL
    SELECT
      id,
      server_id,
      service,
      msg,
      created_at,
      updated_at
    FROM
      logs
    WHERE
      id = $1
    ESQL

    def self.get_log(uuid : String)
      DBH.using_connection do |conn|
        conn.query_one(GET_QUERY, uuid, as: {String, String, String, String, Time, Time})
      end
    rescue
      {nil, nil, nil, nil, nil, nil}
    end

    def self.get_data(
      uuid : String,
      criteria : Array(Hash(String, String))?,
      limit = 500,
      dedups : Array(String)? = [] of String,
      next_from : String? = nil
    )
      where_by_date = MinionAPI::Helpers.where_by_date("created_at", criteria)
      where_by_dedup = ""
      sql_args = MinionAPI::Helpers::SQLArgs.new

      # Always leading with the server_id that we are collecting logs for.
      where_by_uuid = %(server_id = #{sql_args.arg = uuid}\n)

      if !dedups.empty?
        where_by_dedup = <<-EDEDUP
        AND NOT EXISTS
          (
            SELECT
              1
            FROM
              logs
            WHERE
              id IN (DEDUPS)
          )
        EDEDUP

        where_by_dedup.gsub(/(DEDUPS)/) do
          dedups.map { |s| "$#{sql_args.arg = s}" }.join(",")
        end
      end

      where_by_next_from = ""
      if !next_from.nil? && !next_from.empty?
        where_by_next_from = <<-ENEXTFROM
        AND created_at >= $#{sql_args.arg = next_from}
        ENEXTFROM
      end

      where_by_service = ""
      where_by_tsv = ""
      where_by_trgm = ""
      services = [] of String
      fulltexts = [] of String
      keywords = [] of String
      criteria.each do |crt|
        case crt["criteria"]
        when "service"
          services << %(service = '#{sql_args.arg = crt["value"]}')
        when "fulltext"
          fulltexts << crt["value"]
        when "keyword"
          keywords << crt["value"]
        end
      end

      if !services.empty?
        where_by_service = "AND (#{services.join(" OR ")})"
      end

      if !fulltexts.empty?
        where_by_tsv = %(AND (#{
  fulltexts.map do |term|
      MinionAPI::Helpers.parse_input_to_tsv(term)
    end.map do |term|
      %(tsv @@ to_tsquery('english', '#{sql_args.arg = term}'))
    end.join(" OR ")
})\n)
      end

      if !keywords.empty?
        where_by_trgm = %(AND (#{
  keywords.map do |term|
      MinionAPI::Helpers.parse_input_to_ilike(term, "msg", sql_args)
    end.join(" OR ")
}))
      end

      sql = <<-ESQL
      SELECT
        id,
        service,
        msg,
        created_at
      FROM
        logs
      WHERE
        #{where_by_uuid}
        #{where_by_date}
        #{where_by_dedup}
        #{where_by_next_from}
        #{where_by_service}
        #{where_by_tsv}
        #{where_by_trgm}
      ORDER BY
        created_at DESC
      LIMIT #{limit}
      ESQL

      logs = [] of Tuple(String, String, String, Time)
      debug!(sql)
      DBH.using_connection do |conn|
        conn.query_each(sql, args: sql_args.argv) do |rs|
          logs << {
            rs.read(String),
            rs.read(String),
            rs.read(String),
            rs.read(Time),
          }
        end
      end

      logs
    end

    COUNT_SQL = <<-ESQL
    SELECT
      count(*)
    FROM
      logs
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
    property service : String?
    property msg : String?
    property created_at : Time?
    property updated_at : Time?

    def initialize(@uuid : String)
      @name, @created_at = Organization.get_data(@uuid)
    end

    def to_h
      {
        "uuid"       => @uuid,
        "server_id"  => @server_id,
        "service"    => @service,
        "msg"        => @msg,
        "created_at" => @created_at,
        "updated_at" => @updated_at,
      }
    end
  end
end
