require 'rails_helper'

RSpec.describe V1::UserPolicy, type: :policy do
  let(:user) { create(:user) } # Role: Admin
  let(:employee) { create(:user, role: 'Employee') }
  let(:organization) { create(:organization) }
  let!(:organization_user) { create(:organization_user, organization: organization, user: user) }
  let!(:organization_user_employee) { create(:organization_user, organization: organization, user: employee) }
  let!(:user_with_no_orgs) { create(:user, role: 'Employee') }

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
        expect(described_class).to permit(user, user)
      end
      it 'Admin & request info of user associated with same Organization' do
        expect(described_class).to permit(user, employee)
      end
    end
    context 'raise unauthorized if user is' do
      it 'Admin & request info of user is associated with other Organization(s)' do
        expect(described_class).not_to permit(user, user_with_no_orgs)
      end
      it 'not Admin' do
        expect(described_class).not_to permit(employee)
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
        expect(described_class).to permit(user, user)
      end
    end
    context 'raise unauthorized if user is' do
      it 'Admin & try to update user associated with other Organization(s)' do
        expect(described_class).not_to permit(user, user_with_no_orgs)
      end
      it 'not Admin & try to Update other user' do
        expect(described_class).not_to permit(employee, user)
      end
    end
  end

  permissions :edit? do
    context 'grant access if user is' do
      it 'Admin' do
        expect(described_class).to permit(user, user)
      end
    end
  end

  permissions :destroy? do
    context 'grant access if user is' do
      it 'Admin' do
        expect(described_class).to permit(user, user)
      end
    end

    context 'raise unauthorized if user is' do
      it 'not Admin' do
        expect(described_class).not_to permit(employee)
      end
    end
  end

  permissions :me? do
    context 'grant access if user is' do
      it 'Admin' do
        expect(described_class).to permit(user)
      end
      it 'Employee' do
        expect(described_class).to permit(employee)        
      end
    end
  end
end
