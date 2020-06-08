# frozen_string_literal: true

module Minion
  # API - Primary API object. See api/*.rb for other resources
  class Authenticate < Grape::API
    resource :authenticate do
      desc 'Authenticate the user'
      params do
        requires :email, type: String, desc: 'Your email address'
        requires :password, type: String, desc: 'Your password'
      end
      post do
        @user = User.find_by_email(params[:email])
        if @user.authenticate(params[:password])
          # TODO: Issue JWT
          return @user
        end

        return { error: 'Authentication failed' }
      end
    end
  end
end
