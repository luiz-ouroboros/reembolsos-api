class SuppliersController < ApplicationController
  def index
    @suppliers = Supplier.all
    render json: { data: @suppliers }
  end

  def show
    @supplier = Supplier.find(params.permit(:id)[:id])
    render json: @supplier
  end

  def create
    process_usecase(Suppliers::Create) { |result|
      render json: result[:supplier], status: :created
    }
  end

  def update
    process_usecase(Suppliers::Update) { |result| render json: result[:supplier] }
  end

  def destroy
    process_usecase(Suppliers::Destroy) { |_result| head :no_content }
  end
end
