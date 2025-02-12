FactoryBot.define do
  factory :note do
    title { "Test Note" }
    content { "This is a test note." }
    color { "yellow" }
    association :user
  end
end
