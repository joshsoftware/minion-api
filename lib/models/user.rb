# frozen_string_literal: true

# User - represents a user of the platform
class User < Dry::Struct
  transform_keys(&:to_sym)
  # Declare the table we'll use and methods only the app can set
  TABLE = 'users'
  PROTECTED_ATTRIBUTES = %i[id created_at].freeze

  # Using this gives us to_json and from_json
  include Minion::Model

  # Define the attributes for this particular object
  attribute :id, Types::String
  attribute :name, Types::String.optional
  attribute :email, Types::String
  attribute :created_at, Types::Integer.default(Time.now.to_i)

  def self.find_by_email(email)
    $pool.with do |conn|
      cursor = r.table('users').filter do |user|
        user['email'].eq(email)
      end.limit(1).run(conn)
      return User.new(cursor.first)
    end
  end

  def valid?
    # Stop-gap for now, should be a real validation sometime later
    true
  end
end
