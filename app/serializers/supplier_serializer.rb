class SupplierSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :created_at,
             :updated_at,
             :created_by,
             :updated_by
end
