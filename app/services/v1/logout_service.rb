# frozen_string_literal: true

module V1
  class LogoutService
    def initialize(token)
      @token = token
    end

    def logout
      blacklisted_token = BlacklistedToken.create(token: @token[:token])
      if blacklisted_token.valid?
        return { success: true }
      else
        return { 
          success: false,
          errors: blacklisted_token.errors.full_messages
        }
      end
    end
  end
end
