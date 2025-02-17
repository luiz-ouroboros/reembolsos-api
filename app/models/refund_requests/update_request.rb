class RefundRequests::UpdateRequest < UseCase
  attributes :current_user, :params

  class UseContract < ContractScheme
    params do
      required(:id).filled(:integer)
      required(:status).filled(:string, included_in?: [RefundRequest::APPROVED_STATUS, RefundRequest::REPROVED_STATUS])
    end
  end

  def call!
    transaction {
      validate_params(UseContract, params)
        .then(RefundRequests::Find)
        .then(apply(:validate_admin_user))
        .then(:validate_status)
        .then(:update_refund_request)
        .then(:create_log)
    }.then(:output)
  end

  private

  def validate_admin_user(refund_request:, params:, **)
    return Success(:validate_admin_user_success) if current_user.admin?

    Failure(:validation_error, result: build_error(:user_id, 'errors.refund_request.user.not_admin'))
  end

  def validate_status(refund_request:, params:, **)
    return Success(:validate_status_success) if refund_request.requested?

    Failure(:validation_error, result: build_error(:status, 'errors.refund_request.status.not_requested'))
  end

  def update_refund_request(refund_request:, params:, **)
    update_params = params.except(:invoice, :receipt)
    update_params[:"#{params[:status]}_by"] = current_user.email
    update_params[:"#{params[:status]}_at"] = Time.zone.now

    refund_request.update!(update_params)

    Success(:refund_request_updated_success, result: { refund_request: refund_request })
  end

  def create_log(refund_request:, params:, **)
    message = I18n.t(
      "log.refund_request.update_to_#{refund_request.status}",
      id: refund_request.id
    )

    ActionLog.log(
      current_user,
      message,
      refund_request,
      params
    )

    Success(:create_log_success)
  end

  def output(refund_request:, **)
    Success(:update_success, result: { refund_request: refund_request })
  end
end
