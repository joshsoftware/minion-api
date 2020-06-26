require 'rails_helper'

resource 'Users' do
  let(:user) { create(:user) }

  before(:each) do
    add_request_headers(user: user)
  end

  get 'api/v1/me' do
    example 'me' do
      do_request
      expect(status).to eq(200)
    end
  end
end
