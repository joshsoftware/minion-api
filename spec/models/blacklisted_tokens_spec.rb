require 'rails_helper'

RSpec.describe BlacklistedToken, type: :model do
  subject do
    build(:blacklisted_token)
  end

  describe 'validations' do
    it { should validate_presence_of(:token) }
  end
end
