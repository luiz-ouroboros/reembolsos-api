class Supplier < ApplicationRecord
  has_paper_trail

  has_many :refund_requests, dependent: :restrict_with_error
end
