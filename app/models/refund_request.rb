class RefundRequest < ApplicationRecord
  has_paper_trail

  belongs_to :user
  belongs_to :supplier, optional: true

  has_many :refund_request_tags, dependent: :destroy
  has_many :tags, through: :refund_request_tags

  has_one_attached :invoice
  has_one_attached :receipt

  DRAFT_STATUS      = 'draft'.freeze
  REQUESTED_STATUS  = 'requested'.freeze
  APPROVED_STATUS   = 'approved'.freeze
  REPROVED_STATUS   = 'reproved'.freeze
  REIMBURSED_STATUS = 'reimbursed'.freeze

  STATUSES = [
    DRAFT_STATUS,
    REQUESTED_STATUS,
    APPROVED_STATUS,
    REPROVED_STATUS,
    REIMBURSED_STATUS
  ].freeze

  enum :status, {
    draft: DRAFT_STATUS,
    requested: REQUESTED_STATUS,
    approved: APPROVED_STATUS,
    reproved: REPROVED_STATUS,
    reimbursed: REIMBURSED_STATUS,
  }
end
