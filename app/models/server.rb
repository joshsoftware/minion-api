# frozen_string_literal: true

class Server < ApplicationRecord
  include Discard::Model
  default_scope -> { kept }
  validates :addresses, presence: true, uniqueness: true
  belongs_to :organization
end
