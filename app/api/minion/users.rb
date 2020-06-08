# frozen_string_literal: true

module Minion
  # Users - Basic lifecycle management for users
  class Users < Grape::API
    resource :users do
      desc 'Create a new user'
      params do
        requires :name, type: String, desc: 'Your name'
        requires :email, type: String, desc: 'Your email address'
        requires :phone, type: String, desc: 'Your phone number (incl. country code)'
        requires :password, type: String, desc: 'Your desired password (20-72 chars)'
      end
      post do
        u = User.new(
          name: params[:name], email: params[:email],
          phone: params[:phone], password: params[:password]
        )
        return u if u.save

        return u.errors
      end
    end
  end
end
