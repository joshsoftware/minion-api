module MinionAPI
  struct User
    include JSON::Serializable

    SODIUM_MEMLIMIT    = (1024 * 512).to_u64
    SODIUM_OPSLIMIT    = 1024.to_u64
    HashCache          = Minion::SplayTreeMap({String, String}, Bool).new
    HashCacheSizeLimit = 10000 # TODO: SplayTreeMap should support internal size limit context

    def self.authenticate!(email : String?, password : String?) : Bool
      unless email.nil?
        password_digest = uninitialized String
        sql = <<-ESQL
        SELECT
          password_digest
        FROM
          users
        WHERE
          email = $1
        ESQL
        DBH.using_connection do |conn|
          password_digest = conn.query_one(sql, email, as: {String})
        end

        sodium_hash = Sodium::Password::Hash.new
        hash_key = {password_digest.to_s, password}
        cached_hash = HashCache[hash_key]
        if cached_hash
          return cached_hash
        else
          password_status = !!sodium_hash.verify(password_digest.to_s.hexbytes, password)
          HashCache[hash_key] = password_status
          HashCache.prune if HashCache.size > HashCacheSizeLimit
          return password_status
        end
      end

      false
    rescue
      false
    end

    def self.validate(token)
      payload = nil
      begin
        payload, _ = JWT.decode(token, JWT_SECRET, JWT::Algorithm::HS256)
      rescue ex
        pp ex
        User.raise_invalid
      end
      self.new(uuid: payload["uuid"].as_s)
    end

    ALL_UUIDS_SQL = <<-ESQL
    SELECT
      id
    FROM
      users
    ORDER BY
      email ASC
    ESQL

    def self.all
      DBH.using_connection do |conn|
        conn.query_all(ALL_UUIDS_SQL, as: {String}).map do |uuid|
          self.new(uuid).as(User)
        end
      end
    end

    COUNT_SQL = <<-ESQL
    SELECT
      count(*)
    FROM
      users
    ESQL

    def self.count
      DBH.using_connection do |conn|
        conn.query_one(COUNT_SQL, as: {Int64})
      end
    end

    GET_UUID_FROM_EMAIL_QUERY = <<-ESQL
    SELECT
      id
    FROM
      users
    WHERE
      email = $1
    ESQL

    def self.get_uuid_from(email : String)
      DBH.using_connection do |conn|
        conn.query_one(GET_UUID_FROM_EMAIL_QUERY, email, as: {String})
      end
    end

    def self.get_data(uuid : String? = nil, email : String = "")
      if uuid
        get_data_impl(uuid)
      else
        get_data_impl(get_uuid_from(email: email))
      end
    end

    GET_QUERY = <<-ESQL
    SELECT
      u.id,
      u.email,
      u.name,
      u.mobile_number,
      u.administration,
      array_agg(ou.organization_id) AS organizations
    FROM
      users u,
      organization_users ou
    WHERE
      u.id = $1 AND
      ou.user_id = u.id
    GROUP BY
      u.id,
      u.email,
      u.name,
      u.mobile_number,
      u.administration
    ESQL

    def self.get_data_impl(uuid : String)
      DBH.using_connection do |conn|
        conn.query_one(GET_QUERY, uuid, as: {String, String, String, String, Bool, Array(String)})
      end
    rescue
      {nil, nil, nil, nil, nil, nil}
    end

    def self.get_by(email : String)
      self.new(uuid: get_uuid_from(email: email))
      # rescue ex
      #  nil
    end

    def self.find(uuid : String? = nil, email : String = "")
      User.new(uuid, email)
    end

    property uuid : String?
    property email : String?
    property name : String?
    property mobile_number : String?
    property administrator : Bool?
    property organizations : Array(Organization)?

    # @uuid : String?
    # @email : String?
    # @name : String?
    # @mobile_number : String?
    # @administrator : Bool?
    # @organizations : Array(Organization)?
    def initialize(uuid : String? = nil, email : String = "")
      if uuid
        @uuid, @email, @name, @mobile_number, @administrator, organization_ids = User.get_data(uuid: uuid)
      else
        @uuid, @email, @name, @mobile_number, @administrator, organization_ids = User.get_data(email: email)
      end
      if organization_ids.nil?
        @organizations = [] of Organization
      else
        @organizations = organization_ids.map { |o| Organization.new(o) }
      end
    end

    def self.raise_invalid
      raise ART::Exceptions::Unauthorized.new "Invalid username or password.", "Basic realm=\"Minion Dashboard\""
    end

    def to_h
      {
        "uuid":          @uuid,
        "email":         @email,
        "name":          @name,
        "mobile_number": @mobile_number,
        "administrator": @administrator,
        "organizations": @organizations,
      }
    end
  end
end
