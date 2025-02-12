FactoryBot.define do
  factory :refund_request do
    description { "MyText" }
    total { 1.5 }
    paid_at { Time.zone.today }
    status { "MyString" }
    # supplier { nil }
    # requested_by { nil }
    # approved_by { nil }
    # requested_at { nil }
    # approved_at { nil }
    # reimpursed_at { nil }
  end
end
