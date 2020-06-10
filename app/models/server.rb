class Server < ApplicationRecord
  belongs_to :organization
  def self.name
    "#{Faker::Verb.ing_form} #{Faker::Creature::Animal.name}"
  end
end
