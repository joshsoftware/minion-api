# frozen_string_literal: true

require_relative File.join('.', 'users')
require_relative File.join('.', 'authenticate')
require_relative File.join('.', 'servers')

module Minion
  # API - Primary API object. See api/*.rb for other resources
  class API < Grape::API
    format :json
    version :v1
    prefix :api

    mount ::Minion::Users
    mount ::Minion::Authenticate
    mount ::Minion::Servers

    helpers do
      def current_user
        # TODO: Authenticate and locate the user performing the request
        User.first
      end
    end
  end
end
