# frozen_string_literal: true

class User < ApplicationRecord
  include Discard::Model
  has_secure_password
  validates :name, :email, :mobile_number, :password, :role, presence: true
  validates :email, uniqueness: true
  validates :password, length: { minimum: MIN_PASSWORD_LEN }
  validates_format_of :email, with: URI::MailTo::EMAIL_REGEXP
  has_many :organization_users, dependent: :destroy
  has_many :organizations, through: :organization_users
  accepts_nested_attributes_for :organizations

  def admin?
    role == ROLES[:admin]
  end

  def employee?
    role == ROLES[:employee]
  end
end
