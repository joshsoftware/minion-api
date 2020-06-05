# frozen_string_literal: true

module Minion
  # API - Primary API object. See api/*.rb for other resources
  class API < Grape::API
    format :json
    version :v1
    prefix :api

    helpers do
      def current_user
        # TODO: Authenticate and locate the user performing the request
        User.first
      end
    end
  end
end
