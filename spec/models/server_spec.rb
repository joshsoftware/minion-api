require 'rails_helper'

RSpec.describe Server, type: :model do
  subject do
    build(:server)
  end

  describe 'associations' do
    it { should belong_to(:organization) }
  end

  describe 'validations' do
    it { should validate_presence_of(:addresses) }
  end
end
