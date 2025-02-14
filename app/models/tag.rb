class Tag < ApplicationRecord
  has_paper_trail

  has_many :refund_request_tags
  has_many :refund_requests, through: :refund_request_tags
end
