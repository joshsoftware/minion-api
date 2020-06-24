# frozen_string_literal: true

module Api::V1
  class BaseController < ApplicationController
    before_action :authenticate!

    private

    def authenticate!
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
  end
end
