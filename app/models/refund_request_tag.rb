class RefundRequestTag < ApplicationRecord
  belongs_to :refund_equest
  belongs_to :tag
end
