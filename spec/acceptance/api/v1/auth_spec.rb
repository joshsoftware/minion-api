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

    example 'User login' do
      request = {
        "user": {
          "email": user.email,
          "password": user.password
        }
      }

      do_request(request)
      expect(status).to eq(200)
    end
  end

  post '/signup' do
    with_options scope: :user do
      parameter :name, "user's name", required: true
      parameter :email, "user's email", required: true
      parameter :mobile_number, "user's mobile number", required: true
      parameter :password, "user's password", required: true
    end

    example 'User signup' do
      request = {
        "user": {
          "name": Faker::Name.name,
          "email": Faker::Internet.email,
          "mobile_number": Faker::Number.number(digits: 10),
          "password": Faker::Crypto.md5
        }
      }
      do_request(request)
      expect(status).to eq(200)
    end
  end
end
