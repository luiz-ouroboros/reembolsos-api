class SuppliersController < ApplicationController
  before_action :set_supplier, only: [:show, :update, :destroy]

  def index
    @suppliers = Supplier.all
    render json: { data: @suppliers }
  end

  def show
    render json: @supplier
  end

  def create
    @supplier = Supplier.new(supplier_params)
    if @supplier.save
      render json: @supplier, status: :created
    else
      render json: @supplier.errors, status: :unprocessable_entity
    end
  end

  def update
    if @supplier.update(supplier_params)
      render json: @supplier
    else
      render json: @supplier.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @supplier.destroy
    head :no_content
  end

  private

  def set_supplier
    @supplier = Supplier.find(params[:id])
  end

  def supplier_params
    params.permit(:name)
  end
end
