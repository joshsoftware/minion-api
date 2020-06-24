# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  validates :name, :email, :mobile_number, presence: true
  validates :email, uniqueness: true
  validates :password, length: { minimum: 6 }
  validates_format_of :email, with: URI::MailTo::EMAIL_REGEXP
  belongs_to :organization
  belongs_to :role

  def admin?
    role.name == ROLES[:admin]
  end

  def employee?
    role.name == ROLES[:employee]
  end
end
