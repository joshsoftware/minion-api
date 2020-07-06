require 'rails_helper'

resource 'OrganizationUsers' do
  let!(:admin) { create(:user) }
  let!(:user) { create(:user, role: 'Employee') }
  let!(:organization) { create(:organization) }
  let!(:organization_user) { create(:organization_user, organization: organization, user: admin) }

  before(:each) do
    add_request_headers(user: admin)
  end

  post 'api/v1/organization_users' do
    with_options scope: :organization_user do
      parameter :organization_id, "Organization ID", required: true
      parameter :user_id, "User ID", required: true
    end

    example 'create' do
      request = {
        "organization_user": {
          "organization_id": organization.id,
          "user_id": user.id,
        }
      }

      do_request(request)
      expect(status).to eq(201)
    end
  end

  delete 'api/v1/organization_users' do
    parameter :organization_id, "Organization ID", required: true
    parameter :user_id, "User id", required: true
    let!(:membership) { create(:organization_user, organization: organization, user: user) }
    let(:organization_id) { organization.id }
    let(:user_id) { user.id }

    example 'delete' do
      do_request
      expect(status).to eq(200)
    end
  end
end
