class RefundRequests::Get < UseCase
  attributes :current_user, :params

  class UseContract < ContractScheme
    params do
      optional(:search).maybe(:string)
    end
  end

  def call!
    validate_params(UseContract, params)
      .then(:run_query)
  end

  private


  def run_query(params:, **)
    refund_requests = current_user.admin? ? RefundRequest.all : current_user.refund_requests

    if params[:search].present?
      search_term = "%#{params[:search]}%"
      refund_requests = refund_requests.joins(:user, :supplier, :tags).where(
        "refund_requests.description ILIKE :search OR CAST(refund_requests.status as text) ILIKE :search OR users.email ILIKE :search OR users.name ILIKE :search OR suppliers.name ILIKE :search OR tags.name ILIKE :search",
        search: search_term
      ).distinct
    end

    refund_requests = refund_requests.includes(:user, :supplier, :tags)
    refund_requests = refund_requests.order(id: :desc)

    Success(:get_success, result: { refund_requests: refund_requests })
  end
end
