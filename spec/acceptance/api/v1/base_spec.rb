require 'rails_helper'

resource 'Base' do
  get 'api/v1/minion' do
    let!(:agent_version) { create(:agent_version) }

    example 'minion' do
      do_request
      expect(status).to eq(200)
    end
  end
end
