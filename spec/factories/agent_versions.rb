FactoryBot.define do
  factory :agent_version do
    version { Faker::Lorem.characters(number: 20) }
    md5 { Faker::Lorem.characters(number: 20) }
    url { Faker::Internet.url }
  end
end
