class RefundRequests::Create < UseCase
  attributes :current_user, :params

  class UseContract < ContractScheme
    params do
      required(:file_type).filled(:string, included_in?: %w[invoice receipt])
      required(:file).filled(:string)
    end
  end

  def call!
    transaction {
      validate_params(UseContract, params)
        .then(:create_refund_request)
        .then(:attach_file)
        .then(:create_log)
    }.then(:output)
  end

  private

  def create_refund_request(params:, **)
    refund_request = RefundRequest.create!(
      status: RefundRequest::DRAFT_STATUS,
      user: current_user,
      requested_at: Time.zone.now
    )

    Success(:create_refund_request_success, result: { refund_request: refund_request })
  end

  def attach_file(refund_request:, params:, **)
    file_param = params[:file]

    blob = ActiveStorage::Blob.find_signed!(file_param)

    case params[:file_type]
    when 'invoice'
      refund_request.invoice.attach(blob)
    when 'receipt'
      refund_request.receipt.attach(blob)
    else
      return Failure(:invalid_file_type)
    end

    Success(:attach_file_success, result: { refund_request: refund_request })
  rescue ActiveSupport::MessageVerifier::InvalidSignature => e
    Failure(:invalid_file_signature)
  end

  def create_log(refund_request:, params:, **)
    ActionLog.log(
      current_user,
      I18n.t('log.refund_request.create', id: refund_request.id),
      refund_request,
      params
    )

    Success(:create_log_success)
  end

  def output(refund_request:, **)
    Success(:create_success, result: { refund_request: refund_request })
  end
end
