FactoryBot.define do
  factory :user do
    name { "Test User" }
    email { Faker::Internet.email }
    password { "Test@123" } # ✅ Must contain uppercase, lowercase, digit, and special char
    phone_no { "9876543210" } # ✅ Valid Indian phone number
  end
end
