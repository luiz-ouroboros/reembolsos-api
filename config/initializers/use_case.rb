class UseCase < Micro::Case
  def validate_params(contract, params)
    result = contract.new.call(params.deep_symbolize_keys)

    return Success(:validate_params_success, result: { params: result.values.to_h }) if result.success?

    Failure(:validation_error, result: result.errors.to_h)
  end

  def build_error(field, message)
    { field => [I18n.t("#{message}")] }
  end
end
