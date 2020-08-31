module MinionAPI
  struct Server
    GET_QUERY = <<-ESQL
    SELECT
      id,
      aliases,
      addresses,
      organization_id,
      created_at,
      updated_at,
      heartbeat_at
    FROM
      servers
    WHERE
      id = $1
    ESQL

    def self.get_data(uuid)
      DBH.using_connection do |conn|
        conn.query_one(
          GET_QUERY,
          uuid,
          as: {
            Array(String),
            Array(String),
            UUID,
            Time,
            Time,
            Time,
          }
        )
      end
    rescue
      {nil, nil, nil, nil, nil, nil}
    end

    GET_SUMMARY_BY_ORGANIZATION = <<-ESQL
    SELECT
      s.id,
      s.aliases[array_length(s.aliases,1)],
      s.heartbeat_at,
      s.addresses[array_length(s.addresses,1)],
      (
        SELECT
          t.data
        FROM
          telemetries t
        WHERE
          t.server_id = s.id AND
          data ? 'load_avg'
        ORDER BY
          created_at DESC LIMIT 1
      ) AS load_avg,
      s.created_at,
      o.name
    FROM
      servers s,
      organizations o
    WHERE
      s.organization_id IN(ORGS) AND
      s.organization_id = o.id
    ESQL

    def self.get_summary_by(organizations : Array(String))
      sql = GET_SUMMARY_BY_ORGANIZATION
        .sub(
          /ORGS/,
          Array(String).new(organizations.size) { |x| "$#{x + 1}" }.join(",")
        )
      DBH.using_connection do |conn|
        conn.query_all(sql, args: organizations, as: {String, String?, Time, String, JSON::Any?, Time, String})
      end
    rescue ex
      pp ex
      {nil, nil, nil, nil, nil, nil, nil}
    end

    NAMES_SQL = <<-ESQL
    SELECT
      id,
      aliases[array_length(aliases,1)]
    FROM
      servers
    WHERE
      id IN(SERVERS)
    ESQL

    def self.get_names_from_ids(servers : Array(String)) : Hash(String, String?)
      data = {} of String => String?
      arg_n = 0
      debug!(servers)
      names_sql = NAMES_SQL.gsub(/SERVERS/) do
        servers.map { |s| arg_n += 1; "$#{arg_n}" }.join(",")
      end

      debug!(names_sql)
      DBH.using_connection do |conn|
        conn.query_each(names_sql, args: servers) do |rs|
          uuid = rs.read(String)
          name = rs.read(String?)
          data[uuid] = name
        end
      end

      data
    end

    def initialize(@uuid : UUID)
      @aliases, @addresses, @organization_id, @created_at, @updated_at, @heartbeat_at = Server.get_data(@uuid)
    end
  end
end
