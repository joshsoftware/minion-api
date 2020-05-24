class User
  # Declare the table we'll use and methods only the app can set
  TABLE = "users"
  PROTECTED_METHODS = [:@id, :@created_at]

  # Using this gives us to_json and from_json
  include Minion::Model

  # Define the attributes for this particular object
  attr_accessor :id, :name, :email, :created_at

  def initialize(args = {email: nil, name: nil, created_at: nil})
    @id = args[:id]
    @name = args[:name]
    @email = args[:email]
    @created_at = args[:created_at]
  end

  def self.find_by_email(email)
    $pool.with do |conn|
      cursor = r.table('users').filter do |user|
        user['email'].eq(email)
      end.limit(1).run(conn)
      return User.from_json(cursor.first.to_json)
    end
  end

  def valid?
    # Stop-gap for now, should be a real validation sometime later
    true
  end
end
