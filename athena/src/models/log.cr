module MinionAPI
  struct Log
    include JSON::Serializable

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

    def self.get_data(uuid : String)
      DBH.using_connection do |conn|
        conn.query_one(GET_QUERY, uuid, as: {String, String, String, String, Time, Time})
      end
    rescue
      {nil, nil, nil, nil, nil, nil}
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
