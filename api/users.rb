# frozen_string_literal: true

module Minion
  # API - Primary API object. See api/*.rb for other resources
  class API < Grape::API
    resource :users do
      get do
        { status: 'OK' }
      end
    end
  end
end
