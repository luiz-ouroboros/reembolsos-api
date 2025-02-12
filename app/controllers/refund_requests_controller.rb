class RefundRequestsController < ApplicationController
  before_action :set_request, only: [:show, :update, :destroy]

  def index
    @refund_requests = RefundRequest.all
    render json: { data: @refund_requests }
  end

  def show
    render json: @refund_request
  end

  def create
    @refund_request = RefundRequest.new(request_params)
    if @refund_request.save
      render json: @refund_request, status: :created
    else
      render json: @refund_request.errors, status: :unprocessable_entity
    end
  end

  def update
    if @refund_request.update(request_params)
      render json: @refund_request
    else
      render json: @refund_request.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @refund_request.destroy
    head :no_content
  end

  private

  def set_request
    @refund_request = RefundRequest.find(params[:id])
  end

  def request_params
    params.permit(:description, :total, :paid_at, :status, :supplier_id, :requested_at, :approved_at, :reimpursed_at)
  end
end