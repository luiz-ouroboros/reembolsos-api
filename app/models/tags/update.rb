class Tags::Update < UseCase
  attributes :current_user, :params

  class UseContract < ContractScheme
    params do
      required(:id).filled(::Types::Coercible::Integer)
      required(:name).filled(::Types::Tags::Name)
    end
  end

  def call!
    transaction {
      validate_params(UseContract, params)
        .then(Tags::Find)
        .then(apply(:validate_name_uniqueness))
        .then(:update_tag)
        .then(:create_log)
    }.then(:output)
  end

  private

  def validate_name_uniqueness(tag:, params:, **)
    if Tag.where.not(id: tag.id).exists?(name: params[:name])
      return Failure(:validation_error, result: build_error(:name, 'errors.tag.name.unique'))
    end

    Success(:validate_name_uniqueness_success)
  end

  def update_tag(tag:, params:, **)
    tag.update!(
      **params,
      updated_by: current_user.email
    )

    Success(:tag_updated_success, result: { tag: tag })
  end

  def create_log(tag:, params:, **)
    ActionLog.log(
      current_user,
      I18n.t('log.tag.update', name: tag.name),
      tag,
      params
    )

    Success(:create_log_success)
  end

  def output(tag:, **)
    Success(:update_success, result: { tag: tag })
  end
end
