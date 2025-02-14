class Tags::Find < UseCase
  attributes :current_user, :params, :id

  def call!
    tag = Tag.find((params[:id] || id).to_i)

    Success(:find_success, result: { tag: tag })
  end
end
