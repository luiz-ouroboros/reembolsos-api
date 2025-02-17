class RefundRequestSerializer < ActiveModel::Serializer
  attributes :id,
             :description,
             :total,
             :paid_at,
             :status,
             :updated_by,
             :approved_by,
             :reproved_by,
             :requested_at,
             :approved_at,
             :reproved_at,
             :reimpursed_at,
             :latitude,
             :longitude,
             :supplier_id,
             :user_id,
             :tag_ids,
             :created_at,
             :updated_at

  belongs_to :user
  belongs_to :supplier
  has_many :tags

  class UserSerializer < ActiveModel::Serializer
    attributes :id, :email, :name
  end

  class SupplierSerializer < ActiveModel::Serializer
    attributes :id, :name
  end

  class TagSerializer < ActiveModel::Serializer
    attributes :id, :name
  end
end
