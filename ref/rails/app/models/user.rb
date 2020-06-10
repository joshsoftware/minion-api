class User < ApplicationRecord
  belongs_to :organization
  has_secure_password
  validates :email, uniqueness: true
end
