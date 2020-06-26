require 'rails_helper'

RSpec.describe V1::LoginService do
  describe '.login' do
    let!(:user) { create(:user, role: ROLES[:admin]) }

    context 'valid login information of employee' do
      it 'login success' do
        response = V1::LoginService.new(
          user: user,
          password: user.password
        ).login

        expect(response).not_to be_nil
        params = response[:attributes]
        expect(params[:id]).to eq(user.id)
        expect(params[:name]).to eq(user.name)
        expect(params[:email]).to eq(user.email)
        expect(params[:mobile_number]).to eq(user.mobile_number)
        expect(params[:role]).to eq(user.role)
      end
    end

    context 'invalid login information of user' do
      it 'login failed' do
        response = V1::LoginService.new(
          user: user,
          password: Faker::Crypto.md5
        ).login

        expect(response).to eq(false)
      end
    end
  end
end
