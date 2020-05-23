class User
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
    c = r.table('users').filter { |user| user['email'].eq(email) }.limit(1).run($r)
    return User.new.from_json(c.first.to_json)
  end

  def self.find(id)
    return User.new.from_json((r.table("users").get(id).run($r)).to_json)
  end

  def self.create(u)
    # Don't allow spoofing IDs or creation time
    u.created_at = Time.now.utc
    u.id = nil

    # Dump it in there
    r.table('users').insert(u.to_json)

    # Now find it again and return it
    return User.find_by_email(u.email)
  end

  def destroy
  end

  def valid?
  end
end
