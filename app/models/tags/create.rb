class Tags::Create < UseCase
  attributes :current_user, :params

  class UseContract < ContractScheme
    params do
      required(:name).filled(::Types::Tags::Name)
    end
  end

  def call!
    transaction {
      validate_params(UseContract, params)
        .then(:validate_name_uniqueness)
        .then(:create_tag)
        .then(:create_log)
    }.then(:output)
  end

  private

  def validate_name_uniqueness(params:, **)
    if Tag.exists?(name: params[:name])
      return Failure(:validation_error, result: build_error(:name, 'errors.tag.name.unique'))
    end

    Success(:validate_name_uniqueness_success)
  end

  def create_tag(params:, **)
    tag = Tag.create!(
      **params,
      created_by: current_user.email
    )

    Success(:create_tag_success, result: { tag: tag })
  end

  def create_log(tag:, params:, **)
    ActionLog.log(
      current_user,
      I18n.t('log.tag.create', name: tag.name),
      tag,
      params
    )

    Success(:create_log_success)
  end

  def output(tag:, **)
    Success(:create_success, result: { tag: tag })
  end
end
