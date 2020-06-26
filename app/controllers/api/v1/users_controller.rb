# frozen_string_literal: true

module Api::V1
  class UsersController < BaseController
    # before_action :load_organization, except: %i[index show destroy me]
    before_action :load_user, only: %i[show update destroy]
    before_action :load_role, only: :create

    def index
      organization = Organization.find_by(id: params[:organization_id])
      if organization.present?
        users = organization.users
        response = V1::UserSerializer.new(users).serializable_hash
        success_response(data: response[:data])
      else
        error_response(
          message: I18n.t('organization.invalid'),
          status_code: :not_found
        )
      end
    end

    def show
      response = V1::UserSerializer.new(@user).serializable_hash
      success_response(data: response[:data])
    end

    def create
      response = V1::UserService.new(
        role: @role,
        params: user_params
      ).create

      if response[:success]
        success_response(
          message: I18n.t('user.create.success'),
          data: response[:data],
          status_code: :created
        )
      else
        resource_error_response(
          message: I18n.t('user.create.failed'),
          status_code: :unprocessable_entity,
          errors: response[:errors]
        )
      end
    end

    def update
      @user.update(user_params)

      if @user.valid?
        response = V1::UserSerializer.new(@user).serializable_hash
        success_response(
          message: I18n.t('user.update.success'),
          data: response[:data]
        )
      else
        resource_error_response(
          message: I18n.t('user.update.failed'),
          status_code: :unprocessable_entity,
          errors: @user.errors.messages
        )
      end
    end

    def destroy
      if @user.destroy
        success_response(
          message: I18n.t('user.delete.success')
        )
      else
        resource_error_response(
          status_code: :unprocessable_entity,
          message: I18n.t('user.delete.failed'),
          errors: @user.errors.messages
        )
      end
    end

    def me
      response = V1::UserSerializer.new(current_user).serializable_hash
      success_response(data: response[:data])
    end

    private

    def load_role
      if params[:user][:role].present?
        @role = ROLES[params[:user][:role].to_sym]
        return if @role
      end
      error_response(
        message: I18n.t('role.invalid'),
        status_code: :not_found
      )
    end

    def load_user
      @user = User.where(id: params[:id]).first
      return if @user

      error_response(
        message: I18n.t('user.invalid'),
        status_code: :not_found
      )
    end

    def user_params
      params.require(:user).permit(:name, :email, :mobile_number, :password, :role)
    end
  end
end
