require 'rails_helper'

RSpec.describe AgentVersion, type: :model do
  subject do
    build(:agent_version)
  end

  describe 'validations' do
    it { should validate_presence_of(:version) }
    it { should validate_presence_of(:md5) }
    it { should validate_presence_of(:url) }
  end
end
