class User < ApplicationRecord
  has_paper_trail

  devise :database_authenticatable, :registerable,
    :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  DEFAULT_ROLE = 'default'.freeze
  ADMIN_ROLE   = 'admin'.freeze
  ROLES        = [DEFAULT_ROLE, ADMIN_ROLE].freeze

  enum :role, { default: DEFAULT_ROLE, admin: ADMIN_ROLE }

  scope :default, -> { where(role: DEFAULT_ROLE) }
  scope :admin, -> { where(role: ADMIN_ROLE) }

  has_many :refund_requests
end
