require 'rails_helper'

resource 'Servers' do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let!(:organization_user) { create(:organization_user, organization: organization, user: user) }
  let!(:server) { create(:server, organization_id: organization.id) }

  before(:each) do
    add_request_headers(user: user)
  end

  get 'api/v1/servers' do
    example 'index' do
      do_request
      expect(status).to eq(200)
    end
  end

  get 'api/v1/servers/:id' do
    parameter :id, "Servers id", require: true
    let(:id) { server.id }

    example 'show' do
      do_request
      expect(status).to eq(200)
    end
  end

  post 'api/v1/servers' do
    with_options scope: :server do
      parameter :addresses, "servers Addresses", required: true
      parameter :aliases, "servers Aliases"
      parameter :organization_id, "organization id", required: true
    end

    example 'create' do
      request = {
        "server": {
          "addresses": Faker::Internet.ip_v4_address,
          "aliases": Faker::Name.name,
          "organization_id": organization.id
        }
      }

      do_request(request)
      expect(status).to eq(201)
    end
  end

  patch 'api/v1/servers/:id' do
    parameter :id, "server id", required: true
    with_options scope: :server do
      parameter :addresses, "servers Addresses"
      parameter :aliases, "servers Aliases"
      parameter :organization_id, "organization id"
    end

    let(:id) { server.id }

    example 'update' do
      request = {
        "server": {
          "addresses": Faker::Internet.ip_v4_address,
          "aliases": Faker::Name.name,
          "organization_id": organization.id
        }
      }

      do_request(request)
      expect(status).to eq(200)
    end
  end

  delete 'api/v1/servers/:id' do
    parameter :id, "server id", required: true
    let(:id) { server.id }

    example 'delete' do
      do_request
      expect(status).to eq(200)
    end
  end
end
