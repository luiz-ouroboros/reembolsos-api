class Tag < ApplicationRecord
  has_paper_trail

  has_many :request_tags
  has_many :refund_requests, through: :request_tags
end
