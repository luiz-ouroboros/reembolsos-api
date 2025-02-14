class Suppliers::Update < UseCase
  attributes :current_user, :params

  class UseContract < ContractScheme
    params do
      required(:id).filled(::Types::Coercible::Integer)
      required(:name).filled(::Types::Suppliers::Name)
    end
  end

  def call!
    transaction {
      validate_params(UseContract, params)
        .then(Suppliers::Find)
        .then(apply(:validate_name_uniqueness))
        .then(:update_supplier)
        .then(:create_log)
    }.then(:output)
  end

  private

  def validate_name_uniqueness(supplier:, params:, **)
    if Tag.where.not(id: supplier.id).exists?(name: params[:name])
      return Failure(:validation_error, result: build_error(:name, 'errors.supplier.name.unique'))
    end

    Success(:validate_name_uniqueness_success)
  end

  def update_supplier(supplier:, params:, **)
    supplier.update!(
      **params,
      updated_by: current_user.email
    )

    Success(:supplier_updated_success, result: { supplier: supplier })
  end

  def create_log(supplier:, params:, **)
    ActionLog.log(
      current_user,
      I18n.t('log.supplier.update', name: supplier.name),
      supplier,
      params
    )

    Success(:create_log_success)
  end

  def output(supplier:, **)
    Success(:update_success, result: { supplier: supplier })
  end
end
