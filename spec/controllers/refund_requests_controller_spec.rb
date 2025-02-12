require 'rails_helper'

RSpec.describe RefundRequestsController, type: :controller do
  let(:refund_request) { create(:refund_request) }
  let(:valid_attributes) { build(:refund_request).attributes }
  let(:invalid_attributes) {
    { description: nil, total: nil, paid_at: nil, status: nil, supplier_id: nil }
  }
  let(:refund_request_pattern) {
    {
      id: Integer,
      description: String,
      total: Float,
      paid_at: I18n.t('regexp.date'),
      status: String,
      supplier_id: nil,
      requested_by: nil,
      approved_by: nil,
      requested_at: nil,
      approved_at: nil,
      reimpursed_at: nil,
      created_at: I18n.t('regexp.datetime'),
      updated_at: I18n.t('regexp.datetime'),
    }
  }

  describe 'GET #index' do
    it 'returns a success response' do
      refund_request_pattern[:id] = refund_request.id
      pattern                     = { data: [refund_request_pattern] }

      get :index

      expect(response).to be_successful
      expect(response.body).to be_json_as(pattern)
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      pattern      = refund_request_pattern
      pattern[:id] = refund_request.id

      get :show, params: { id: refund_request.id }

      expect(response).to be_successful
      expect(response.body).to be_json_as(pattern)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new RefundRequest' do
        pattern               = refund_request_pattern
        pattern[:description] = valid_attributes['description']
        pattern[:total]       = valid_attributes['total']

        post :create, params: valid_attributes

        expect(response).to have_http_status(:created)
        expect(response.body).to be_json_as(pattern)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested refund_request' do
        pattern               = refund_request_pattern
        pattern[:description] = valid_attributes['description']
        pattern[:total]       = valid_attributes['total']

        put :update, params: { **valid_attributes, id: refund_request.id }

        expect(response).to have_http_status(:ok)
        expect(response.body).to be_json_as(pattern)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested refund_request' do
      refund_request_to_delete = RefundRequest.create!(valid_attributes)

      delete :destroy, params: { id: refund_request_to_delete.id }

      expect(response).to have_http_status(:no_content)
      expect(RefundRequest.exists?(refund_request_to_delete.id)).to be_falsey
    end
  end
end