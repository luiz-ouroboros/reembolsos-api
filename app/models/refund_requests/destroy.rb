class RefundRequests::Destroy < UseCase
  attributes :current_user, :params

  class UseContract < ContractScheme
    params do
      required(:id).filled(:integer)
    end
  end

  def call!
    transaction {
      validate_params(UseContract, params)
        .then(RefundRequests::Find)
        .then(apply(:validate_status))
        .then(:destroy_refund_request)
        .then(:create_log)
    }.then(:output)
  end

  private

  def validate_status(refund_request:, params:, **)
    return Success(:validate_status_success) if refund_request.draft?

    Failure(:validation_error, result: build_error(:status, 'errors.refund_request.status.not_draft'))
  end

  def destroy_refund_request(refund_request:, params:, **)
    refund_request.destroy

    Success(:refund_request_destroyed_success, result: { refund_request: refund_request })
  end

  def create_log(refund_request:, params:, **)
    ActionLog.log(
      current_user,
      I18n.t('log.refund_request.destroy', id: refund_request.id),
      refund_request,
      params
    )

    Success(:create_log_success)
  end

  def output(refund_request:, **)
    Success(:destroy_success, result: { refund_request: refund_request })
  end
end
