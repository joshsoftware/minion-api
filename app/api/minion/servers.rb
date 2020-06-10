# frozen_string_literal: true

module Minion
  class Servers < Grape::API
    resource :servers do
      desc "Registers a server"
      params do
        requires :org_id, type: Integer, desc: 'Your organization ID'
      end
      post :register do
        @org = Organization.find(params[:org_id])
        @server = Server.new(organization: @org, last_checkin_at: Time.now.utc, name: Server.name, config: {})
        return @server if @server.save
        return @serv.errors
      end
    end
  end
end
