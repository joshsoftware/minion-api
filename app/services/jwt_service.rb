# frozen_string_literal: true

class JwtService
  JWT_ALGORITHM = 'HS256'

  def self.encode(user)
    payload = {
      id: user.id,
      exp: Time.current.to_i + AUTH_TOKEN_EXPIRY
    }

    JWT.encode(
      payload,
      Rails.application.secrets.secret_key_base,
      JWT_ALGORITHM
    )
  end

  def self.decode(token)
    JWT.decode(
      token,
      Rails.application.secrets.secret_key_base,
      true,
      { algorithm: JWT_ALGORITHM }
    )
  end
end
