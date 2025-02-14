class Users::Find < UseCase
  attributes :current_user, :params, :id

  def call!
    user = User.find((params[:id] || id).to_i)

    Success(:find_success, result: { user: user })
  end
end
