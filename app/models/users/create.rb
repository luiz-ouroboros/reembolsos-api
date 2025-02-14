class Users::Create < UseCase
  attributes :current_user, :params

  class UseContract < ContractScheme
    params do
      required(:name).filled(::Types::StringUntil255)
      required(:email).filled(::Types::Email)
      required(:role).filled(::Types::Users::Roles)
    end
  end

  def call!
    transaction {
      validate_params(UseContract, params)
        .then(:validate_email_uniqueness)
        .then(:create_user)
        .then(:create_log)
    }.then(:output)
  end

  private

  def validate_email_uniqueness(params:, **)
    if User.exists?(email: params[:email])
      return Failure(:validation_error, result: build_error(:email, 'errors.user.email.unique'))
    end

    Success(:email_uniqueness_validated_success)
  end

  def create_user(params:, **)
    user = User.create!(
      **params,
      created_by: current_user.email,
      active: true
    )

    Success(:create_user_success, result: { user: user })
  end

  def create_log(user:, params:, **)
    ActionLog.log(
      current_user,
      I18n.t('log.user.create', email: user.email),
      user,
      params
    )


    Success(:create_log_success)
  end

  def output(user:, **)
    Success(:create_success, result: { user: user })
  end
end
