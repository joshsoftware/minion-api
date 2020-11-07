require "minion-common/minion/uuid"

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
    ) : Array(Tuple(String, String, String, Time, Float64))
      where_by_date = MinionAPI::Helpers.where_by_date("created_at", criteria)
      where_by_dedup = ""
      sql_args = MinionAPI::Helpers::SQLArgs.new

      # Always leading with the server_id that we are collecting logs for.
      where_by_uuid = %(server_id = $#{sql_args.arg = uuid}\n)

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

      where_by_service = ""
      where_by_tsv = ""
      where_by_trgm = ""
      services = [] of String
      fulltexts = [] of String
      keywords = [] of String
      criteria.each do |crt|
        debug!(crt)
        case crt["criteria"]
        when "service"
          services << %(service = $#{sql_args.arg = crt["value"]})
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
      %(tsv @@ to_tsquery('english', $#{sql_args.arg = term}))
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

      debug!("calculating next_from #{next_from}")
      where_by_next_from = ""
      if !next_from.nil? && !next_from.empty?
        # 1) Get the record pointed to by next_from.
        # 2) Get it's created_at date.
        sql = <<-ESQL
        SELECT
          created_at
        FROM
          logs
        WHERE
          id = $1
        ESQL

        debug!("a")
        created_at = nil
        DBH.using_connection do |conn|
          conn.query_each(sql, args: [next_from]) do |rs|
            created_at = rs.read(Time)
          end
        end

        # 3) Get it's specific timestamp from it's UUID.
        timestamp = Minion::UUID.new(next_from).utc
        debug!(timestamp)

        # 4) Query all records which are for the same second.
        sql = <<-ESQL
        SELECT
          id
        FROM
          logs
        WHERE
          created_at = '#{created_at.not_nil!.to_s("%Y-%m-%d %H:%M:%S.%N")}'::timestamp AND
          #{where_by_uuid}
          #{where_by_date}
          #{where_by_dedup}
          #{where_by_service}
          #{where_by_tsv}
          #{where_by_trgm}
        ORDER BY
          created_at DESC
        ESQL
        debug!(sql)

        possible_duplicates = [] of Minion::UUID
        DBH.using_connection do |conn|
          conn.query_each(
            sql,
            args: sql_args.argv
          ) do |rs|
            possible_duplicates << Minion::UUID.new(rs.read(String))
          end
        end
        debug!(possible_duplicates)

        # 5) Find the ones which are from before the next_from record,
        #    according to their UUID timestamps.
        duplicates = timestamp.nil? ? [] of Minion::UUID : possible_duplicates.select do |pd|
          debug!("#{pd.utc} <= #{timestamp}")
          pd.utc.not_nil! <= timestamp
        end

        # 6) Write SQL to query >= the timestamp, but to exclude all
        #    records that are too old in that second.

        if duplicates.empty?
          and_id_not_in = ""
        else
          and_id_not_in = <<-EANDIDNOTIN
          AND id NOT IN (#{duplicates.map { |d| "$#{sql_args.arg = d.to_s}" }.join(",")})
          EANDIDNOTIN
        end

        where_by_next_from = <<-ENEXTFROM
        -- where_by_next_from
        AND created_at >= $#{sql_args.arg = created_at.not_nil!.to_s("%Y-%m-%d %H:%M:%S.%N")}
        #{and_id_not_in}
        ENEXTFROM
        debug!(where_by_next_from)
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
        #{where_by_service}
        #{where_by_tsv}
        #{where_by_trgm}
        #{where_by_next_from}
      ORDER BY
        created_at DESC
      LIMIT #{limit}
      ESQL

      logs = [] of Tuple(String, String, String, Time, Float64)
      debug!(sql)
      debug!(sql_args.argv)
      DBH.using_connection do |conn|
        conn.query_each(sql, args: sql_args.argv) do |rs|
          t_id = rs.read(String)
          t_service = rs.read(String)
          t_msg = rs.read(String)
          t_created_at = rs.read(Time)
          t_create_at_to_f = t_created_at.to_unix_f
          logs << {
            t_id,
            t_service,
            t_msg,
            t_created_at,
            t_create_at_to_f,
          }
        end
      end

      logs
    end

    ACCURATE_COUNT_SQL = <<-ESQL
    SELECT
      count(*)
    FROM
      logs
    ESQL

    FAST_COUNT_SQL = <<-ESQL
    SELECT
      count_estimate('SELECT 1 FROM LOGS')
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
