class RefundRequests::UpdateProcess < UseCase
  attributes :current_user, :params

  class UseContract < ContractScheme
    params do
      required(:id).filled(:integer)
      required(:status).filled(:string, included_in?: RefundRequest::STATUSES)
      optional(:description).filled(::Types::StringUntil255)
      optional(:total).filled(:float)
      optional(:paid_at).filled(:date)
      optional(:supplier_id).filled(:integer)
      optional(:invoice).filled(Types::File)
      optional(:receipt).filled(Types::File)
    end
  end

  def call!
    validate_params(UseContract, params)
      .then(RefundRequests::Find)
      .then(apply(:run_user_case))
      .then(:output)
  end

  private

  def run_user_case(refund_request:, params:, **)
    case
    when refund_request.draft?
      call(RefundRequests::UpdateDraft, params)
    when refund_request.requested?
      call(RefundRequests::UpdateRequest, params)
    when refund_request.reproved?
      call(RefundRequests::UpdateDraft, params)
    end
  end

  def output(refund_request:, **)
    Success(:update_success, result: { refund_request: refund_request })
  end
end
