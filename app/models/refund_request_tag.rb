class RefundRequestTag < ApplicationRecord
  belongs_to :refund_request
  belongs_to :tag
end
