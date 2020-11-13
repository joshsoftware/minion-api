module MinionAPI
  struct Server
    GET_QUERY = <<-ESQL
    SELECT
      id::varchar,
      aliases,
      addresses,
      organization_id::varchar,
      created_at,
      updated_at,
      heartbeat_at
    FROM
      servers
    WHERE
      id = $1
    ESQL

    def self.get_data(uuid)
      MinionAPI.dbh(
        default: {
          "",
          Array(String).new,
          Array(String).new,
          UUID.random,
          Time.local,
          Time.local,
          Time.local,
        }
      ) do |dbh|
        dbh.query_one(
          GET_QUERY,
          uuid,
          as: {
            String,
            Array(String),
            Array(String),
            UUID,
            Time,
            Time,
            Time,
          }
        )
      end
    end

    # This code won't bother finding a load average older than
    # 10 minutes because that is just pretty useless in the summary.
    GET_SUMMARY_BY_ORGANIZATION = <<-ESQL
    SELECT
      s.id::varchar,
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
          t.data ? 'load_avg' AND
          t.created_at > (now() - interval '10 minutes')
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
      debug!(sql)
      MinionAPI.dbh(default: {"","",Time.local,"",nil,Time.local,""}) do |dbh|
        dbh.query_all(sql, args: organizations, as: {String, String?, Time, String, JSON::Any?, Time, String})
      end
    end

    NAMES_SQL = <<-ESQL
    SELECT
      id::varchar,
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
      MinionAPI.dbh(default: data) do |dbh|
        dbh.query_each(names_sql, args: servers) do |rs|
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
