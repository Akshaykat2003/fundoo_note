FactoryBot.define do
  factory :user do
    name { "Test User" }
    email { Faker::Internet.unique.email }
    password { "Test@123" } # ✅ Valid password format
    phone_no { "9#{Faker::Number.number(digits: 9)}" } # ✅ Always starts with 9
  end
end
