class Suppliers::Destroy < UseCase
  attributes :current_user, :params

  class UseContract < ContractScheme
    params do
      required(:id).filled(::Types::Coercible::Integer)
    end
  end

  def call!
    transaction {
      validate_params(UseContract, params)
        .then(Suppliers::Find)
        .then(apply(:validate_refund_request_association))
        .then(:destroy_supplier)
        .then(:create_log)
    }.then(:output)
  end

  private

  def validate_refund_request_association(supplier:, **)
    if supplier.refund_requests.exists?
      return Failure(:validation_error, result: build_error(:error, 'errors.supplier.refund_request_association'))
    end

    Success(:validate_refund_request_association_success)
  end

  def destroy_supplier(supplier:, params:, **)
    supplier.destroy

    Success(:supplier_destroyed_success, result: { supplier: supplier })
  end

  def create_log(supplier:, params:, **)
    ActionLog.log(
      current_user,
      I18n.t('log.supplier.destroy', name: supplier.name),
      supplier,
      params
    )

    Success(:create_log_success)
  end

  def output(supplier:, **)
    Success(:destroy_success, result: { supplier: supplier })
  end
end
