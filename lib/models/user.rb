require 'rethinkdb'

class Minion
  class User
    attr_accessor :name, :email, :created_at

    def find_by_email(email)
    end
  end
end
