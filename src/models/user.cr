module MinionAPI
  struct User
    include JSON::Serializable

    SODIUM_MEMLIMIT    = (1024 * 512).to_u64
    SODIUM_OPSLIMIT    = 1024.to_u64
    HashCache          = SplayTreeMap({String, String}, Bool).new
    HashCacheSizeLimit = 10000 # TODO: SplayTreeMap should support internal size limit context

    def self.authenticate!(email : String?, password : String?) : Bool
      unless email.nil?
        sql = <<-ESQL
        SELECT
          password_digest
        FROM
          users
        WHERE
          email = $1
        ESQL
        password_digest = MinionAPI.dbh { |dbh| dbh.query_one(sql, email, as: {String}) }

        sodium_hash = Sodium::Password::Hash.new
        hash_key = {password_digest.to_s, password}
        debug!("Validating #{email} -- #{password} -- #{hash_key.inspect}.cached? #{HashCache.has_key?(hash_key)}")
        cached_hash = HashCache[hash_key]?
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
        debug!(token)
        payload, other = JWT.decode(token, JWT_SECRET, JWT::Algorithm::HS256)
        debug!(other)
      rescue ex
        pp ex
        User.raise_invalid
      end
      debug!(payload)
      self.new(uuid: payload["uuid"].as_s)
    end

    ALL_UUIDS_SQL = <<-ESQL
    SELECT
      id::varchar
    FROM
      users
    ORDER BY
      email ASC
    ESQL

    def self.all
      MinionAPI.dbh(default: [""]) do |dbh|
        dbh.query_all(ALL_UUIDS_SQL, as: {String})
      end.map do |uuid|
        self.new(uuid).as(User)
      end
    end

    COUNT_SQL = <<-ESQL
    SELECT
      count(*)
    FROM
      users
    ESQL

    def self.count
      MinionAPI.dbh { |dbh| dbh.query_one(COUNT_SQL, as: {Int64}) }
    end

    GET_UUID_FROM_EMAIL_QUERY = <<-ESQL
    SELECT
      id::varchar
    FROM
      users
    WHERE
      email = $1
    ESQL

    def self.get_uuid_from(email : String)
      MinionAPI.dbh { |dbh| dbh.query_one(GET_UUID_FROM_EMAIL_QUERY, email, as: {String}) }
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
      u.id::varchar,
      u.email,
      u.name,
      u.mobile_number,
      u.administration,
      array_agg(ou.organization_id::varchar) AS organizations
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
      debug!("Querying: #{GET_QUERY}\nWITH: #{uuid}\n")
      MinionAPI.dbh(default = {"", "", "", "", false, [] of String}) do |dbh|
        dbh.query_one(GET_QUERY, uuid, as: {String, String, String, String, Bool, Array(String)})
      end
    end

    def self.get_data_impl(uuid : UUID)
      get_data_impl(uuid.to_s)
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
        _uuid, @email, @name, @mobile_number, @administrator, organization_ids = User.get_data(uuid: uuid)
      else
        _uuid, @email, @name, @mobile_number, @administrator, organization_ids = User.get_data(email: email)
      end
      @uuid = _uuid.to_s

      if organization_ids.nil?
        @organizations = [] of Organization
      else
        @organizations = organization_ids.map { |o| Organization.new(o) }
      end
      debug!(self)
    end

    def initialize(uuid : UUID = nil, email : String = "")
      initialize(uuid: uuid.to_s, email: email)
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
