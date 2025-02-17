FactoryBot.define do
  factory :refund_request do
    # description { Faker::Name.name }
    # total { 1.5 }
    # paid_at { Time.zone.today }
    status { RefundRequest::DRAFT_STATUS }
    supplier { association :supplier }
    tag_ids { [create(:tag).id] }
    user { association :user }
    # approved_by { nil }
    requested_at { Time.zone.now }
    # approved_at { nil }
    # reimpursed_at { nil }
  end
end
