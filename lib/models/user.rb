require 'rethinkdb'
require 'json'
require 'pry'

require_relative File.join('..', 'jsonable.rb')

class Minion
  class User
    # Using this gives us to_json and from_json
    include Minion::JSONAble

    # Define the attributes for this particular object
    attr_accessor :id, :name, :email, :created_at

    def initialize(args = {email: nil, name: nil, created_at: nil})
      @name = args[:name]
      @email = args[:email]
      @created_at = args[:created_at]
    end

    def self.find_by_email(email)
    end

    def self.create(u)
      u.created_at = Time.now.utc
    end

    def destroy
    end

    def valid?
    end

  end
end
binding.pry
