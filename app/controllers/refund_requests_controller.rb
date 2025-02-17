class RefundRequestsController < BaseController
  def index
    process_usecase(RefundRequests::Get) { |result|
      render json: result[:refund_requests], root: :data, adapter: :json
    }
  end

  def show
    process_usecase(RefundRequests::Find) { |result|
      render json: result[:refund_request], root: false
    }
  end

  def create
    process_usecase(RefundRequests::Create) { |result|
      render json: result[:refund_request], status: :created
    }
  end

  def update
    process_usecase(RefundRequests::UpdateProcess) { |result| render json: result[:refund_request] }
  end

  def destroy
    process_usecase(RefundRequests::Destroy) { |_result| head :no_content }
  end
end
