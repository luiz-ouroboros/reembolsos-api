FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    role { User::DEFAULT_ROLE }
    active { true }
    created_by { Faker::Internet.email }
  end
end
