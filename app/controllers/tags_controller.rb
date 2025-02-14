class TagsController < ApplicationController
  def index
    @tags = Tag.all
    render json: { data: @tags }
  end

  def show
    @tag = Tag.find(params.permit(:id)[:id])
    render json: @tag
  end

  def create
    process_usecase(Tags::Create) { |result|
      render json: result[:tag], status: :created
    }
  end

  def update
    process_usecase(Tags::Update) { |result| render json: result[:tag] }
  end

  def destroy
    process_usecase(Tags::Destroy) { |_result| head :no_content }
  end
end
