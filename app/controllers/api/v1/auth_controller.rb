# frozen_string_literal: true

module Api::V1
  class AuthController < BaseController
    skip_before_action :authenticate!, except: :logout
    before_action :load_user, only: :login

    def login
      data = V1::LoginService.new(
        user: @user,
        password: params[:user][:password]
      ).login

      if data
        success_response(
          message: I18n.t('auth.login.success'),
          data: data
        )
      else
        error_response(
          message: I18n.t('auth.login.failed'),
          status_code: :unauthorized
        )
      end
    end

    def signup
      data = V1::SignupService.new(
        params: signup_params,
        role: ROLES[:admin],
      ).signup

      if data[:success]
        success_response(
          message: I18n.t('auth.signup.success')
        )
      else
        resource_error_response(
          message: I18n.t('auth.signup.failed'),
          status_code: :unprocessable_entity,
          errors: data[:errors]
        )
      end
    end

    def logout
      token = request.headers[HTTP_AUTH_HEADER]
      data = V1::LogoutService.new(
        token: token
      ).logout

      if data[:success]
        success_response(
          message: I18n.t('auth.logout.success')
        )
      else
        resource_error_response(
          message: I18n.t('auth.logout.failed'),
          status_code: :unprocessable_entity,
          errors: data[:errors]
        )
      end
    end

    private

    def signup_params
      params.require(:user).permit(:name, :email, :mobile_number, :password,
                                   organizations_attributes: %i[name])
    end

    def load_user
      @user = User.where(email: params[:user][:email]).first
      return if @user

      error_response(
        message: I18n.t('auth.login.failed'),
        status_code: :unauthorized
      )
    end
  end
end
