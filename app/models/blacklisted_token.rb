# frozen_string_literal: true

class BlacklistedToken < ApplicationRecord
  validates :token, presence: true
end
