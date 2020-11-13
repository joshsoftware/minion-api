# TODO: Write documentation for `MinionAPI`
require "./core"

module MinionAPI
  @@dbh : DB::Database? = nil

  def self.create_database_connection
    begin
      @@dbh = DB.open(CONFIG.pgurl)
    rescue DB::ConnectionRefused
      puts "Database connection refused: #{CONFIG.pgurl}"
    end
  end

  def self.dbh
    @@dbh.not_nil!
  end

  def self.default_values_for(obj : Int.class)
    obj.new(0)
  end

  def self.default_values_for(obj : String.class)
    ""
  end

  def self.default_values_for(obj : Float.class)
    obj.new(0.0)
  end

  def self.default_values_for(obj : Bool.class)
    false
  end

  def self.default_values_for(obj : Nil.class)
    nil
  end

  def self.dbh(&blk : DB::Database -> D) forall D
    default_object = default_values_for(D)
    dbh(default: default_object, &blk)
  end

  def self.dbh(default : D, &) forall D
    begin
      yield @@dbh.not_nil!
    rescue ex : Exception
      debug!("Database Error: #{ex}")
      default ? default : raise ex
    end
  end

  create_database_connection
  JWT_SECRET = CONFIG.jwt
  ART.run(host: CONFIG.host, port: CONFIG.port)
end
