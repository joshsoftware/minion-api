module V1
  class UserPolicy < ApplicationPolicy
    def index?
      user.admin?
    end

    def show?
      (user.admin? && validate_organization) || user == record
    end

    def create?
      user.admin?
    end

    def new?
      create?
    end

    def update?
      (user.admin? && validate_organization) || user == record
    end

    def edit?
      update?
    end

    def destroy?
      user.admin? && validate_organization
    end

    def me?
      true
    end

    private

    def validate_organization
      if record.present? && record.organizations.present?
        user_orgs = user.organizations
        record_orgs = record.organizations
        return (record_orgs - user_orgs).empty?
      end
    end
  end
end
