# frozen_string_literal: true

# User: Represents a user in the system
class User < ApplicationRecord
  include ActiveModel::SecurePassword
  has_secure_password
  belongs_to :org
end
