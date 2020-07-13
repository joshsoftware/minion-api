FactoryBot.define do
  factory :server do
    addresses { [Faker::Internet.ip_v4_address] }
    aliases { [Faker::Name.name] }
  end
end
