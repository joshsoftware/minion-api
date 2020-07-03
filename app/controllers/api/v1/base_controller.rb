# frozen_string_literal: true

module Api::V1
  class BaseController < ApplicationController
    before_action :authenticate!, except: :minion

    def minion
      latest_version = AgentVersion.last.as_json(except: :id)
      return success_response(data: latest_version) if latest_version
      error_response(
        message: I18n.t('agent_version.failed'),
        status_code: :unauthorized
      )
    end

    private

    def authenticate!
      validate_token
      current_user
    rescue JWT::ExpiredSignature
      error_response(
        message: I18n.t('session.invalid'),
        status_code: :unauthorized
      )
    rescue JWT::DecodeError
      error_response(
        message: I18n.t('session.invalid'),
        status_code: :unauthorized
      )
    end

    def current_user
      @current_user ||= User.find_by(
        id: jwt_payload['id']
      )
    end

    def jwt_payload
      @jwt_payload ||= JwtService.decode(
        request.headers[HTTP_AUTH_HEADER]
      ).first
    end

    def validate_token
      token = request.headers[HTTP_AUTH_HEADER]
      raise JWT::ExpiredSignature if BlacklistedToken.find_by(token: token)
    end
  end
end
