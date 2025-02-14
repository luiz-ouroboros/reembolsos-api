class Users::Update < UseCase
  attributes :current_user, :params

  class UseContract < ContractScheme
    params do
      required(:id).filled(::Types::Coercible::Integer)
      required(:name).filled(::Types::StringUntil255)
      required(:role).filled(::Types::Users::Roles)
      required(:active).filled(:bool)
    end
  end

  def call!
    transaction {
      validate_params(UseContract, params)
        .then(Users::Find)
        .then(apply(:update_user))
        .then(:create_log)
      }.then(:output)
  end

  private

  def update_user(user:, params:, **)
    user.update!(
      **params,
      updated_by: current_user.email
    )

    Success(:user_created_success, result: { user: user })
  end

  def create_log(user:, params:, **)
    ActionLog.log(
      current_user,
      I18n.t('log.user.update', email: user.email),
      user,
      params
    )

    Success(:create_log_success)
  end

  def output(user:, **)
    Success(:create_success, result: { user: user })
  end
end
