class RefundRequests::UpdateDraft < UseCase
  attributes :current_user, :params

  class UseContract < ContractScheme
    params do
      required(:id).filled(:integer)
      required(:status).filled(:string, included_in?: [RefundRequest::DRAFT_STATUS, RefundRequest::REQUESTED_STATUS])
      optional(:description).filled(::Types::StringUntil255)
      optional(:total).filled(:float)
      optional(:paid_at).filled(:date)
      optional(:supplier_id).filled(:integer)
      optional(:tag_ids).filled(:array).each(:integer)
      optional(:invoice).filled(Types::File)
      optional(:receipt).filled(Types::File)
    end
  end

  def call!
    transaction {
      validate_params(UseContract, params)
        .then(RefundRequests::Find)
        .then(apply(:validate_owner))
        .then(:validate_status)
        .then(:update_refund_request)
        .then(:maybe_update_invoice_file)
        .then(:maybe_update_receipt_file)
        .then(:create_log)
    }.then(:output)
  end

  private

  def validate_owner(refund_request:, params:, **)
    return Success(:validate_owner_success) if refund_request.user_id == current_user.id

    Failure(:validation_error, result: build_error(:user_id, 'errors.refund_request.user.not_owner'))
  end

  def validate_status(refund_request:, params:, **)
    return Success(:validate_status_success) if refund_request.draft?

    Failure(:validation_error, result: build_error(:status, 'errors.refund_request.status.not_draft'))
  end

  def update_refund_request(refund_request:, params:, **)
    update_params = params.except(:invoice, :receipt)
    update_params[:updated_by] = current_user.email
    update_params[:requested_at] = Time.zone.now if params[:status] == RefundRequest::REQUESTED_STATUS

    refund_request.update!(update_params)

    Success(:refund_request_updated_success, result: { refund_request: refund_request })
  end

  def maybe_update_invoice_file(refund_request:, params:, **)
    return Success(:missing_file) unless params[:invoice]

    refund_request.invoice.attach(
      io: params[:invoice].tempfile,
      filename: params[:invoice].original_filename,
      content_type: params[:invoice].content_type,
    )

    ActionLog.log(
      current_user,
      I18n.t('log.refund_request.update_invoice', id: refund_request.id),
      refund_request,
      params
    )

    Success(:maybe_update_invoice_file_success, result: { refund_request: refund_request })
  end

  def maybe_update_receipt_file(refund_request:, params:, **)
    return Success(:missing_file) unless params[:receipt]

    refund_request.receipt.attach(
      io: params[:receipt].tempfile,
      filename: params[:receipt].original_filename,
      content_type: params[:receipt].content_type,
    )

    ActionLog.log(
      current_user,
      I18n.t('log.refund_request.update_receipt', id: refund_request.id),
      refund_request,
      params
    )

    Success(:maybe_update_receipt_file_success, result: { refund_request: refund_request })
  end

  def create_log(refund_request:, params:, **)
    message = I18n.t(
      "log.refund_request.#{refund_request.draft? ? 'update' : 'update_to_requested'}",
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
