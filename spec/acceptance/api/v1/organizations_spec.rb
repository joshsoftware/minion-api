require 'rails_helper'

resource 'Organizations' do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let!(:organization_user) { create(:organization_user, organization: organization, user: user) }

  before(:each) do
    add_request_headers(user: user)
  end

  get 'api/v1/organizations' do
    example 'index' do
      do_request
      expect(status).to eq(200)
    end
  end

  get 'api/v1/organizations/:id' do
    parameter :id, "Organization id", require: true
    let(:id) { organization.id }

    example 'show' do
      do_request
      expect(status).to eq(200)
    end
  end

  post 'api/v1/organizations' do
    with_options scope: :organization do
      parameter :name, "organization's name", required: true
    end

    example 'create' do
      request = {
        "organization": {
          "name": Faker::Name.name
        }
      }

      do_request(request)
      expect(status).to eq(201)
    end
  end

  patch 'api/v1/organizations/:id' do
    parameter :id, "organization id", required: true
    with_options scope: :organization do
      parameter :name, "organization's name"
    end

    let(:id) { organization.id }

    example 'update' do
      request = {
        "organization": {
          "name": Faker::Name.name
        }
      }

      do_request(request)
      expect(status).to eq(200)
    end
  end

  delete 'api/v1/organizations/:id' do
    parameter :id, "organization id", required: true
    let(:id) { organization.id }

    example 'delete' do
      do_request
      expect(status).to eq(200)
    end
  end
end
