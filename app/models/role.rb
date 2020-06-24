# frozen_string_literal: true

class Role < ApplicationRecord
  validates :name, uniqueness: true, presence: true
  has_many :users
end
