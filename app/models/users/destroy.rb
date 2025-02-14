class Users::Destroy < UseCase
  attributes :current_user, :params

  class UseContract < ContractScheme
    params do
      required(:id).filled(::Types::Coercible::Integer)
    end
  end

  def call!
    transaction {
      validate_params(UseContract, params)
        .then(Users::Find)
        .then(apply(:destroy_user))
        .then(:create_log)
      }.then(:output)
  end

  private
  def destroy_user(user:, params:, **)
    user.destroy

    Success(:user_created_success, result: { user: user })
  end

  def create_log(user:, params:, **)
    ActionLog.log(
      current_user,
      I18n.t('log.user.destroy', email: user.email),
      user,
      params
    )

    Success(:create_log_success)
  end

  def output(user:, **)
    Success(:create_success, result: { user: user })
  end
end
