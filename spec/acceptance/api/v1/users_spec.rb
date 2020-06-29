require 'rails_helper'

resource 'Users' do
  let(:user) { create(:user) }

  before(:each) do
    add_request_headers(user: user)
  end

  get 'api/v1/me' do
    example 'me' do
      do_request
      expect(status).to eq(200)
    end
  end

  get 'api/v1/users/:id' do
    parameter :id, "User id", require: true
    let(:id) { user.id }

    example 'show' do
      do_request
      expect(status).to eq(200)
    end
  end

  post 'api/v1/users' do
    with_options scope: :user do
      parameter :name, "user's name", required: true
      parameter :email, "user's email", required: true
      parameter :mobile_number, "user's mobile number", required: true
      parameter :role, "user's role"
    end

    example 'create' do
      request = {
        "user": {
          "name": Faker::Name.name,
          "email": Faker::Internet.email,
          "mobile_number": Faker::Number.number(digits: 10),
          "password": Faker::Lorem.characters(number: 12),
          "role": "employee"
        }
      }

      do_request(request)
      expect(status).to eq(201)
    end

    example 'Should not create an user with invalid Role' do
      request = {
        "user": {
          "name": Faker::Name.name,
          "email": Faker::Internet.email,
          "mobile_number": Faker::Number.number(digits: 10),
          "password": Faker::Lorem.characters(number: 12),
          "role": Faker::Name.name
        }
      }

      do_request(request)
      expect(status).to eq(404)
    end
  end

  patch 'api/v1/users/:id' do
    parameter :id, "user id", required: true
    with_options scope: :user do
      parameter :email, "user's email"
      parameter :mobile_number, "user's mobile number"
      parameter :name, "user's name"
      parameter :password, "user's password"
      parameter :role, "user's role"
    end

    let(:id) { user.id }

    example 'update' do
      request = {
        "user": {
          "name": Faker::Name.name,
          "email": Faker::Internet.email,
          "mobile_number": Faker::Number.number(digits: 10),
          "password": Faker::Lorem.characters(number: 12),
          "role": 'admin'
        }
      }

      do_request(request)
      expect(status).to eq(200)
    end
  end

  delete 'api/v1/users/:id' do
    parameter :id, "user id", required: true
    let(:id) { user.id }

    example 'delete' do
      do_request
      expect(status).to eq(200)
    end
  end

  get 'api/v1/users' do
    parameter :organization_id, required: true
    let(:organization) { create(:organization) }
    let(:organization_id) { organization.id }

    example 'index' do
      do_request
      expect(status).to eq(200)
    end
  end
end
