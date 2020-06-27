# frozen_string_literal: true

class ApplicationController < ActionController::API
  def error_response(message:, errors: nil, status_code: nil)
    render json: {
      message: message,
      errors: errors,
      success: false
    },
    status: status_code
  end

  def success_response(message: nil, data: nil, status_code: 200)
    render json: {
      data: data,
      success: true,
      message: message
    },
    status: status_code
  end

  def resource_error_response(message:, errors:, status_code:)
    formatted_errors = errors.map do |error_title, error_message|
      {
        "#{error_title}": error_message
      }
    end

    error_response(
      message: message,
      errors: formatted_errors,
      status_code: status_code
    )
  end

  private

  def user_not_authorized
    error_response(
      message: I18n.t('session.access_denied'), status_code: :forbidden
    )
  end
end
