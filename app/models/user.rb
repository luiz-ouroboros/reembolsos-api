class User < ApplicationRecord
  has_paper_trail

  devise :database_authenticatable, :registerable,
    :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null
end
