# frozen_string_literal: true

module V1
  class LoginService
    def initialize(user: nil, password: nil)
      @user = user
      @password = password
    end

    def login
      return false unless @user.authenticate(@password)

      response = V1::UserLoginSerializer.new(@user).serializable_hash
      response[:data]
    end
  end
end
