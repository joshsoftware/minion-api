require 'rails_helper'

RSpec.describe V1::OrganizationPolicy, type: :policy do
  let(:user) { create(:user) } # Role: Admin
  let(:employee) { create(:user, role: 'Employee') }
  let(:organization) { create(:organization) }
  let(:organization_with_no_user) { create(:organization) }
  let!(:organization_user) { create(:organization_user, organization: organization, user: user) }
  let!(:organization_user_employee) { create(:organization_user, organization: organization, user: employee) }

  permissions :index? do
    context 'grant access if user is' do
      it 'Admin' do
        expect(described_class).to permit(user)
      end
    end

    context 'raise unauthorized if user is' do
      it 'not Admin' do
        expect(described_class).not_to permit(employee)
      end
    end
  end

  permissions :show? do
    context 'grant access if user is' do
      it 'Admin' do
        expect(described_class).to permit(user, organization)
      end
      it 'not Admin' do
        expect(described_class).to permit(employee, organization)
      end
    end

    context 'raise Unauthorized if an Organization is not asssociated with any' do
      it 'Admin' do
        expect(described_class).not_to permit(user, organization_with_no_user)
      end
      it 'Employee' do
        expect(described_class).not_to permit(employee, organization_with_no_user)
      end
    end
  end

  permissions :create? do
    context 'grant access if user is' do
      it 'Admin' do
        expect(described_class).to permit(user)
      end
    end

    context 'raise unauthorized if user is' do
      it 'not Admin' do
        expect(described_class).not_to permit(employee)
      end
    end
  end

  permissions :new? do
    context 'grant access if user is' do
      it 'Admin' do
        expect(described_class).to permit(user)
      end
    end

    context 'raise unauthorized if user is' do
      it 'not Admin' do
        expect(described_class).not_to permit(employee)
      end
    end
  end

  permissions :update? do
    context 'grant access if user is' do
      it 'Admin' do
        expect(described_class).to permit(user, organization)
      end
    end
  end

  permissions :edit? do
    context 'grant access if user is' do
      it 'Admin' do
        expect(described_class).to permit(user, organization)
      end
    end
  end

  permissions :destroy? do
    context 'grant access if user is' do
      it 'Admin' do
        expect(described_class).to permit(user, organization)
      end
    end

    context 'raise unauthorized if user is' do
      it 'not Admin' do
        expect(described_class).not_to permit(employee, organization)
      end
      it 'not belongs to an organization' do
        expect(described_class).not_to permit(user, organization_with_no_user)
      end
    end
  end
end
