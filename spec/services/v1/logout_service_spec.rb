require 'rails_helper'

RSpec.describe V1::LogoutService do
  describe '.logout' do
    it 'successfully' do
      response = V1::LogoutService.new(
        token: Faker::Lorem.characters(number: 150),
      ).logout

      expect(response[:success]).to eq(true)
    end
  end
end
