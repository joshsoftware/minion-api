# frozen_string_literal: true

module Api::V1
  class OrganizationUsersController < BaseController
    before_action :load_organization_user, only: %i[destroy]
    before_action :authorize_organization_user

    def create
      organization_user = OrganizationUser.new(organization_users_params)

      if organization_user.save
        success_response(
          message: I18n.t('organization_user.create.success'),
          status_code: :created
        )
      else
        resource_error_response(
          message: I18n.t('organization_user.create.failed'),
          status_code: :unprocessable_entity,
          errors: organization_user.errors.messages
        )
      end
    end

    def destroy
      if @organization_user.destroy
        success_response(
          message: I18n.t('organization_user.delete.success')
        )
      else
        resource_error_response(
          status_code: :unprocessable_entity,
          message: I18n.t('organization_user.delete.failed'),
          errors: @organization_user.errors.messages
        )
      end
    end

    private

    def load_organization_user
      @organization_user = OrganizationUser.where(organization_id: params[:organization_id],
                                                  user_id: params[:user_id]).last
      return if @organization_user
      error_response(
        message: I18n.t('organization_user.invalid'),
        status_code: :not_found
      )
    end

    def authorize_organization_user
      if @organization_user
        authorize @organization_user.organization_id, policy_class: V1::OrganizationUserPolicy
      else
        organization = Organization.find_by(id: organization_users_params[:organization_id])
        authorize organization.id, policy_class: V1::OrganizationUserPolicy
      end
    end

    def organization_users_params
      params.require(:organization_user).permit(:organization_id, :user_id)
    end
  end
end
