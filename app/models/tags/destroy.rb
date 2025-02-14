class Tags::Destroy < UseCase
  attributes :current_user, :params

  class UseContract < ContractScheme
    params do
      required(:id).filled(::Types::Coercible::Integer)
    end
  end

  def call!
    transaction {
      validate_params(UseContract, params)
        .then(Tags::Find)
        .then(apply(:validate_refund_request_association))
        .then(:destroy_tag)
        .then(:create_log)
    }.then(:output)
  end

  private

  def validate_refund_request_association(tag:, **)
    if tag.refund_requests.exists?
      return Failure(:validation_error, result: build_error(:error, 'errors.tag.refund_request_association'))
    end

    Success(:validate_refund_request_association_success)
  end

  def destroy_tag(tag:, params:, **)
    tag.destroy

    Success(:tag_destroyed_success, result: { tag: tag })
  end

  def create_log(tag:, params:, **)
    ActionLog.log(
      current_user,
      I18n.t('log.tag.destroy', name: tag.name),
      tag,
      params
    )

    Success(:create_log_success)
  end

  def output(tag:, **)
    Success(:destroy_success, result: { tag: tag })
  end
end
