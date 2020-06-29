FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    role { "Admin" }
    email { Faker::Internet.email }
    mobile_number { Faker::Number.number(digits: 10) }
    password  { "Password123456" }
  end
end
