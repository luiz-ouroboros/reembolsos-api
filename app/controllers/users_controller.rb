class UsersController < ApplicationController
  def index
    @users = User.all
    render json: { data: @users }
  end

  def show
    @user = User.find(params.permit(:id)[:id])

    render json: @user
  end

  def create
    process_usecase(Users::Create) { |result|
      render json: result[:user], status: :created
    }
  end

  def update
    process_usecase(Users::Update) { |result| render json: result[:user] }
  end

  def destroy
    process_usecase(Users::Destroy) { |_result| head :no_content }
  end
end
