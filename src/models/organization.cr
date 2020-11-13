module MinionAPI
  struct Organization
    include JSON::Serializable

    ALL_UUIDS_SQL = <<-ESQL
    SELECT
      id::varchar
    FROM
      organizations
    ORDER BY
      name ASC
    ESQL

    def self.all
      MinionAPI.dbh(default: Array(String).new) { |dbh| dbh.query_all(ALL_UUIDS_SQL, as: {String}) }.map do |uuid|
        self.new(uuid).as(Organization)
      end
    end

    GET_QUERY = <<-ESQL
    SELECT
      name,
      created_at
    FROM
      organizations
    WHERE
      id = $1
    ESQL

    def self.get_data(uuid) : {String?, Time?}
      MinionAPI.dbh(default: {"", Time.local}) { |dbh| dbh.query_one(GET_QUERY, uuid, as: {String, Time}) }
    rescue
      {nil, nil}
    end

    property uuid : String?
    property name : String?
    property created_at : Time?

    def initialize(@uuid : String)
      @name, @created_at = Organization.get_data(@uuid)
    end

    def initialize(_uuid : UUID)
      initialize(_uuid.to_s)
    end

    def initialize(@uuid : String, @name : String?, @created_at : Time?)
    end

    SERVERS_SQL = <<-ESQL
    SELECT
      id::varchar
    FROM
      servers
    WHERE
      organization_id = $1
    ORDER BY
      created_at
    ESQL

    def servers
      MinionAPI.dbh { |dbh| dbh.query_all(SERVERS_SQL, @uuid, as: {String}) }.map do |uuid|
        Server.new(uuid)
      end
    end

    USERS_SQL = <<-ESQL
    SELECT
      id::varchar
    FROM
      users
    WHERE
      organization_id = $1
    ORDER BY
      name
    ESQL

    def users
      MinionAPI.dbh { |dbh| dbh.query_all(USERS_SQL, @uuid, as: {String}) }.map do |uuid|
        User.new(uuid)
      end
    end

    SERVERS_COUNT_SQL = <<-ESQL
    SELECT
      count(*)
    FROM
      servers
    WHERE
      organization_id = $1
    ESQL

    def server_count : Int64
      MinionAPI.dbh { |dbh| dbh.query_one(SERVERS_COUNT_SQL, @uuid, as: {Int64}) }
    end

    USERS_COUNT_SQL = <<-ESQL
    SELECT
      count(*)
    FROM
      organization_users
    WHERE
      organization_id = $1
    ESQL

    def user_count : Int64
      MinionAPI.dbh { |dbh| dbh.query_one(USERS_COUNT_SQL, @uuid, as: {Int64}) }
    end

    def to_h
      {
        "uuid"         => @uuid,
        "name"         => @name,
        "created_at"   => @created_at,
        "server_count" => server_count,
        "user_count"   => user_count,
      }
    end
  end
end
