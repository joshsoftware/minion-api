# frozen_string_literal: true

# Organization model
class Org < ApplicationRecord
  has_one :admin
end
