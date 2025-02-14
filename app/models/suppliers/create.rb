class Suppliers::Create < UseCase
  attributes :current_user, :params

  class UseContract < ContractScheme
    params do
      required(:name).filled(::Types::Suppliers::Name)
    end
  end

  def call!
    transaction {
      validate_params(UseContract, params)
        .then(:validate_name_uniqueness)
        .then(:create_supplier)
        .then(:create_log)
    }.then(:output)
  end

  private

  def validate_name_uniqueness(params:, **)
    if Supplier.exists?(name: params[:name])
      return Failure(:validation_error, result: build_error(:name, 'errors.supplier.name.unique'))
    end

    Success(:validate_name_uniqueness_success)
  end

  def create_supplier(params:, **)
    supplier = Supplier.create!(
      **params,
      created_by: current_user.email
    )

    Success(:create_supplier_success, result: { supplier: supplier })
  end

  def create_log(supplier:, params:, **)
    ActionLog.log(
      current_user,
      I18n.t('log.supplier.create', name: supplier.name),
      supplier,
      params
    )

    Success(:create_log_success)
  end

  def output(supplier:, **)
    Success(:create_success, result: { supplier: supplier })
  end
end