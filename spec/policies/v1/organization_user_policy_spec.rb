require 'rails_helper'

RSpec.describe V1::OrganizationUserPolicy, type: :policy do
  let(:user) { create(:user) }
  let(:employee) { create(:user, role: 'Employee') }
  let(:organization) { create(:organization) }
  let(:new_organization) { create(:organization) }
  let!(:organization_user) { create(:organization_user, organization: organization, user: user) }

  permissions :create? do
    context 'grant access if user is' do
      it 'Admin' do
        expect(described_class).to permit(user, organization.id)
      end
    end

    context 'raise unauthorized if user is' do
      it 'not Admin' do
        expect(described_class).not_to permit(employee, organization.id)
      end
    end
  end

  permissions :destroy? do
    context 'grant access if user is' do
      it 'Admin' do
        expect(described_class).to permit(user, organization.id)
      end
    end

    context 'raise unauthorized if user is' do
      it 'not Admin' do
        expect(described_class).not_to permit(employee, organization.id)
      end
      it 'not belongs to an organization' do
        expect(described_class).not_to permit(user, new_organization.id)
      end
    end
  end
end
