# frozen_string_literal: true

module V1
  class OrganizationService
    def initialize(params: nil, admin:)
      @params = params
      @user = admin
    end

    def create
      organization = Organization.new(@params)
      if @user.present? && organization.save
        OrganizationUser.create(organization_id: organization.id, user_id: @user.id)
        { success: true, data: V1::OrganizationSerializer.new(organization).serializable_hash[:data] }
      else
        { success: false, errors: organization.errors.messages }
      end
    end
  end
end
