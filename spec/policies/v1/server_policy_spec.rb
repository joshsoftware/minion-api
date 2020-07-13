require 'rails_helper'

RSpec.describe V1::ServerPolicy, type: :policy do
  let(:user) { create(:user) }
  let(:employee) { create(:user, role: 'Employee') }
  let(:organization) { create(:organization) }
  let!(:organization_user) { create(:organization_user, organization: organization, user: user) }
  let!(:server) { create(:server, organization_id: organization.id) }
  let!(:organization_user_employee) { create(:organization_user, organization: organization, user: employee) }
  let(:admin_user) { create(:user) }
  let(:other_user) { create(:user, role: 'Employee') }

  permissions :index? do
    context 'grant access' do
      it 'for all type of users' do
        expect(described_class).to permit(user)
        expect(described_class).to permit(employee)        
      end
    end
  end

  permissions :show? do
    context 'grant access if user is' do
      it 'associated with requested Server' do
        expect(described_class).to permit(user, server.organization_id)
        expect(described_class).to permit(employee, server.organization_id)
      end
    end

    context 'If Organization is not asssociated with user' do
      it 'raise Unauthorized' do
        expect(described_class).not_to permit(admin_user, server.organization_id)
        expect(described_class).not_to permit(other_user, server.organization_id)
      end
    end
  end

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

  permissions :new? do
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

  permissions :update? do
    context 'grant access if user is' do
      it 'Admin' do
        expect(described_class).to permit(user, server.organization_id)
      end
    end

    context 'raise unauthorized if user is' do
      it 'not Admin' do
        expect(described_class).not_to permit(employee, organization.id)
      end
    end
  end

  permissions :edit? do
    context 'grant access if user is' do
      it 'Admin' do
        expect(described_class).to permit(user, server.organization_id)
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
        expect(described_class).to permit(user, server.organization_id)
      end
    end

    context 'raise unauthorized if user is' do
      it 'not Admin' do
        expect(described_class).not_to permit(employee, server.organization_id)
      end
      it 'not belongs to an organization' do
        expect(described_class).not_to permit(admin_user, server.organization_id)
      end
    end
  end
end
