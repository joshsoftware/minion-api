# frozen_string_literal: true

module Minion
  # API - Primary API object. See api/*.rb for other resources
  class API < Grape::API
    resource :users do
      desc 'Create a new user'
      params do
        requires :name, type: String, desc: 'Your name'
        requires :email, type: String, desc: 'Your email address'
        requires :phone, type: String, desc: 'Your phone number (incl. country code)'
        requires :password, type: String, desc: 'Your desired password (20-72 chars)'
      end
      post do
        u = User.new
        u.name = params[:name]
        u.email = params[:email]
        u.phone = params[:phone]
        u.password = params[:password]
        if u.valid?
          u.save
          attrs = u.attributes
          attrs.delete('password_digest')
          return attrs
        else
          return u.errors
        end
      end
    end
  end
end
