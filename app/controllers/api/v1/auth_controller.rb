# frozen_string_literal: true

module Api::V1
  class AuthController < BaseController
    skip_before_action :authenticate!
    before_action :load_organization, :load_role, only: :signup
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
        role: @role,
        organization: @organization
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

    private

    def signup_params
      params.require(:user).permit(:name, :email, :mobile_number, :password, :organization_id)
    end

    def load_organization
      @organization = Organization.find_by(id: params[:user][:organization_id])
      return if @organization

      error_response(
        message: I18n.t('organization.invalid'),
        status_code: :bad_request
      )
    end

    def load_role
      @role = Role.where(name: ROLES[:employee]).first
      return if @role

      error_response(
        message: I18n.t('user.role.not_found', ROLES[:employee]),
        status_code: :not_found
      )
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
