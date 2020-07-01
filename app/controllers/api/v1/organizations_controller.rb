# frozen_string_literal: true

module Api::V1
  class OrganizationsController < BaseController
    before_action :load_organization, only: %i[show update destroy]
    before_action :authorize_organization

    def index
      organizations = current_user.organizations
      response = V1::OrganizationSerializer.new(organizations).serializable_hash
      success_response(data: response[:data])
    end

    def show
      response = V1::OrganizationSerializer.new(@organization).serializable_hash
      success_response(data: response[:data])
    end

    def create
      response = V1::OrganizationService.new(
        params: organization_params,
        admin: current_user
      ).create

      if response[:success]
        success_response(
          message: I18n.t('organization.create.success'),
          data: response[:data],
          status_code: :created
        )
      else
        resource_error_response(
          message: I18n.t('organization.create.failed'),
          status_code: :unprocessable_entity,
          errors: response[:errors]
        )
      end
    end

    def update
      @organization.update(organization_params)

      if @organization.valid?
        response = V1::OrganizationSerializer.new(@organization).serializable_hash
        success_response(
          message: I18n.t('organization.update.success'),
          data: response[:data]
        )
      else
        resource_error_response(
          message: I18n.t('organization.update.failed'),
          status_code: :unprocessable_entity,
          errors: @organization.errors.messages
        )
      end
    end

    def destroy
      if @organization.discard
        success_response(
          message: I18n.t('organization.delete.success')
        )
      else
        resource_error_response(
          status_code: :unprocessable_entity,
          message: I18n.t('organization.delete.failed'),
          errors: @organization.errors.messages
        )
      end
    end

    private

    def load_organization
      @organization = Organization.find_by(id: params[:id])
    end

    def organization_params
      params.require(:organization).permit(:name)
    end

    def authorize_organization
      if @organization.present?
        authorize @organization, policy_class: V1::OrganizationPolicy
      else
        authorize current_user, policy_class: V1::OrganizationPolicy
      end
    end
  end
end
