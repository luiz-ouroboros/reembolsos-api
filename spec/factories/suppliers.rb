FactoryBot.define do
  factory :supplier do
    name { Faker::Company.name.upcase }
    created_by { Faker::Internet.email }
    updated_by { nil }
  end
end
