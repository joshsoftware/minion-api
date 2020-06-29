require 'rails_helper'

RSpec.describe Organization, type: :model do
  subject do
    build(:organization)
  end

  describe 'associations' do
    it { should have_many(:organization_users) }
    it { should have_many(:users).through(:organization_users) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end
end
