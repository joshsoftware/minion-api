class Server < ApplicationRecord
  belongs_to :organization
  def self.name
    "TODO: Faker Name"
  end
end
