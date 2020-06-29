require 'rails_helper'

RSpec.describe User, type: :model do
  subject do
    build(:user)
  end

  describe 'associations' do
    it { should have_many(:organization_users) }
    it { should have_many(:organizations).through(:organization_users) }
    it { should accept_nested_attributes_for(:organizations) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_presence_of(:mobile_number) }
    it { should allow_value(Faker::Internet.email).for(:email) }
    it { should_not allow_value('fake@.com').for(:email) }
    it { should have_secure_password }
  end

  describe 'methods' do
    it 'it should verify user is Admin or not' do
      user = build(:user, role: ROLES[:admin])
      response = user.admin?
      expect(response).to eq(true)
    end

    it 'it should verify user is Employee or not' do
      user = build(:user, role: ROLES[:employee])
      response = user.employee?
      expect(response).to eq(true)
    end
  end
end
