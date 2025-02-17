class RefundRequests::Find < UseCase
  attributes :current_user, :params, :id

  def call!
    refund_request = RefundRequest.find((params[:id] || id).to_i)

    Success(:find_success, result: { refund_request: refund_request })
  end
end
