require 'rails_helper'

RSpec.describe V1::SignupService do
  describe '.signup' do
    let!(:user) do
      create(
        :user,
        name: "Minion",
        email: "minion@test.com",
        mobile_number: "1111111111",
        password: Faker::Crypto.md5,
        role: ROLES[:admin]
      )
    end

    let!(:valid_signup_params) do
      {
        "name": Faker::Name.name,
        "email": Faker::Internet.email,
        "mobile_number": Faker::Number.number(digits: 10),
        "password": Faker::Crypto.md5
      }
    end

    let!(:invalid_signup_params) do
      {
        "name": "Minion",
        "email": "minion@test.com",
        "mobile_number": "1111111111",
        "password": Faker::Crypto.md5
      }
    end

    context 'valid information of User' do
      it 'creation success' do
        response = V1::SignupService.new(
          params: valid_signup_params,
          role: ROLES[:admin],
        ).signup

        expect(response[:success]).to eq(true)
        user = User.find_by(name: valid_signup_params[:name])
        expect(user.email).to eq(valid_signup_params[:email])
        expect(user.mobile_number.to_i).to eq(valid_signup_params[:mobile_number])
      end
    end

    context 'duplicate information of User' do
      it 'creation failed' do
        response = V1::SignupService.new(
          params: invalid_signup_params,
          role: ROLES[:admin]
        ).signup

        expect(response[:success]).to eq(false)
        errors = response[:errors]
        expect(errors).not_to be_nil
        expect(errors.first).to eq("Email has already been taken")
        expect(errors.last).to eq("Mobile number has already been taken")
      end
    end
  end
end
