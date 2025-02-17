ActiveRecord::Base.transaction do
  # Create user admin
  admin_user = User.create!(email: ENV['ADMIN_USER_EMAIL'], password: ENV['ADMIN_USER_EMAIL'], role: User::ADMIN_ROLE)
  default_user = User.create!(email: ENV['DEFAULT_USER_EMAIL'], password: ENV['DEFAULT_USER_EMAIL'], role: User::DEFAULT_ROLE)

  # Create tags
  tags = ['Food', 'Clothing', 'Electronics', 'Home', 'Beauty', 'Sports', 'Toys', 'Books', 'Music', 'Movies']
  tags.each do |tag|
    Tag.create(name: tag)
  end

  # Create suppliers
  suppliers = ['Amazon', 'Walmart', 'Target', 'Best Buy', 'Costco', 'Kroger', 'Safeway', 'Albertsons', 'Walgreens', 'CVS']
  suppliers.each do |supplier|
    Supplier.create(name: supplier)
  end

  # Create a refund requests to each status draft, requested, approved and reimbursed
  refund_requests = [
    {
      user_id: admin_user.id,
      supplier_id: 1,
      total: 100.0,
      description: 'Almoço no restaurante',
      status: RefundRequest::DRAFT_STATUS,
      tag_ids: [1]
    },
    {
      user_id: admin_user.id,
      supplier_id: 2,
      total: 200.0,
      description: 'Almoço no restaurante',
      status: RefundRequest::REQUESTED_STATUS,
      tag_ids: [1]
    },
    {
      user_id: admin_user.id,
      supplier_id: 2,
      total: 200.0,
      description: 'Almoço no restaurante',
      status: RefundRequest::APPROVED_STATUS,
      tag_ids: [1]
    },
    {
      user_id: admin_user.id,
      supplier_id: 2,
      total: 200.0,
      description: 'Almoço no restaurante',
      status: RefundRequest::REPROVED_STATUS,
      tag_ids: [1]
    },
    {
      user_id: admin_user.id,
      supplier_id: 2,
      total: 200.0,
      description: 'Almoço no restaurante',
      status: RefundRequest::REIMBURSED_STATUS,
      tag_ids: [1]
    }
  ]

  refund_requests.each do |refund_request|
    RefundRequest.create(refund_request)
  end
end
