class RefundRequest < ApplicationRecord
  has_paper_trail

  belongs_to :supplier, optional: true

  has_many :request_tags
  has_many :tags, through: :request_tags

  has_one_attached :invoice
  has_one_attached :receipt
end
