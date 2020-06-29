# frozen_string_literal: true

class Organization < ApplicationRecord
  include Discard::Model
  validates :name, presence: true, uniqueness: true
  has_many :organization_users, dependent: :destroy
  has_many :users, through: :organization_users
end
