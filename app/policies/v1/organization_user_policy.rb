module V1
  class OrganizationUserPolicy < ApplicationPolicy
    def create?
      user.admin? && validate_organization
    end

    def destroy?
      user.admin? && validate_organization
    end

    private

    def validate_organization
      return user.organizations.pluck(:organization_id).include?(record) if record.present?
      false
    end
  end
end
