module V1
  class ServerPolicy < ApplicationPolicy
    def index?
      true
    end

    def show?
      validate_organization
    end

    def create?
      user.admin? && validate_organization
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
      return user.organizations.pluck(:id).include?(record) if record.present?
      false
    end
  end
end
