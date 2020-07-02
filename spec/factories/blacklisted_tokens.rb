FactoryBot.define do
  factory :blacklisted_token do
    token { Faker::Lorem.characters(number: 150) }
  end
end
