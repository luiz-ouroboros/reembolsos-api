class RefundRequests::Get < UseCase
  attributes :current_user, :params

  class UseContract < ContractScheme
    params do
      optional(:search).maybe(:string)
      optional(:supplier_id).maybe(:integer)
    end
  end

  def call!
    validate_params(UseContract, params)
      .then(:load_refund_requests)
      .then(:includes)
      .then(:filter_by_supplier)
      .then(:search)
      .then(:order)
      .then(:output)
  end

  private

  def load_refund_requests(params:, **)
    refund_requests = current_user.admin? ? RefundRequest.all : current_user.refund_requests

    Success(:load_refund_requests_success, result: { refund_requests: refund_requests })
  end

  def includes(refund_requests:, **)
    Success(:includes_success, result: {
      refund_requests: refund_requests.includes(:user, :supplier, :tags)
    })
  end

  def filter_by_supplier(refund_requests:, params:, **)
    return Success(:ilter_by_supplier_skipped) if params[:supplier_id].blank?

    Success(:filter_by_supplier_success, result: {
      refund_requests: refund_requests.where(supplier_id: params[:supplier_id])
    })
  end

  def search(refund_requests:, params:, **)
    return Success(:search_skipped) if params[:search].blank?

    search_term = "%#{params[:search]}%"

    refund_requests_table  = RefundRequest.arel_table
    users_table            = User.arel_table
    suppliers_table        = Supplier.arel_table
    tags_table             = Tag.arel_table

    condition_description   = refund_requests_table[:description].matches(search_term, nil, true)
    condition_status        = refund_requests_table[:status].matches(search_term, nil, false)
    condition_user_email    = users_table[:email].matches(search_term, nil, false)
    condition_user_name     = users_table[:name].matches(search_term, nil, true)
    condition_supplier_name = suppliers_table[:name].matches(search_term, nil, false)
    condition_tag_name      = tags_table[:name].matches(search_term, nil, false)

    combined_condition = condition_description
      .or(condition_status)
      .or(condition_user_email)
      .or(condition_user_name)
      .or(condition_supplier_name)
      .or(condition_tag_name)

    refund_requests = refund_requests
      .joins(:user, :supplier, :tags)
      .where(combined_condition)
      .distinct

    Success(:search_success, result: { refund_requests: refund_requests })
  end

  def order(refund_requests:, **)
    Success(:order_success, result: {
      refund_requests: refund_requests.order(id: :desc)
    })
  end

  def output(refund_requests:, **)
    Success(:get_success, result: { refund_requests: refund_requests })
  end
end
