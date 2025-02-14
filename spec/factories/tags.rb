FactoryBot.define do
  factory :tag do
    name { Faker::Lorem.word.upcase }
    created_by { Faker::Internet.email }
  end
end
