require 'rails_helper'

resource 'Auth' do
  before(:each) do
    add_request_headers
  end

  post '/login' do
    let!(:user) { create(:user, password: Faker::Lorem.characters(number: 12)) }

    with_options scope: :user do
      parameter :email, "user's email", required: true
      parameter :password, "user's password", required: true
    end

    example 'login' do
      request = {
        "user": {
          "email": user.email,
          "password": user.password
        }
      }

      do_request(request)
      expect(status).to eq(200)
    end

    example 'Invalid login credentials' do
      request = {
        "user": {
          "email": user.email,
          "password": Faker::Lorem.characters(number: 12)
        }
      }

      do_request(request)
      expect(status).to eq(401)

      request = {
        "user": {
          "email": Faker::Internet.email,
          "password": user.password
        }
      }

      do_request(request)
      expect(status).to eq(401)
    end
  end

  post '/signup' do
    with_options scope: :user do
      parameter :name, "user's name", required: true
      parameter :email, "user's email", required: true
      parameter :mobile_number, "user's mobile number", required: true
      parameter :password, "user's password", required: true
      with_options scope: :organizations_attributes do
        parameter :name, "organization's name", required: true
      end
    end

    example 'signup' do
      request = {
        "user": {
          "name": Faker::Name.name,
          "email": Faker::Internet.email,
          "mobile_number": Faker::Number.number(digits: 10),
          "password": Faker::Crypto.md5,
          "organizations_attributes": [{ "name": Faker::Name.name }]
        }
      }
      do_request(request)
      expect(status).to eq(200)
    end
  end

  get '/logout' do
    let!(:user) { create(:user) }

    example 'logout' do
      add_request_headers(user: user)
      do_request
      expect(status).to eq(200)
    end
  end
end
