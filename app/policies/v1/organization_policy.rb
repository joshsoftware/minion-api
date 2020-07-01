module V1
  class OrganizationPolicy < ApplicationPolicy
    def index?
      user.admin?
    end

    def show?
      validate_organization
    end

    def create?
      user.admin?
    end

    def new?
      create?
    end

    def update?
      user.admin? && validate_organization
    end

    def edit?
      update?
    end

    def destroy?
      user.admin? && validate_organization
    end

    private

    def validate_organization
      return user.organizations.include?(record) if record.present?
      false
    end
  end
end
