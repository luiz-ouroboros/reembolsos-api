require 'rails_helper'

RSpec.describe RefundRequestsController, type: :controller do
  let(:refund_request) { create(:refund_request) }
  let(:valid_attributes) { attributes_for(:refund_request) }
  let(:refund_request_pattern) {
    {
      id: Integer,
      description: nil,
      total: nil,
      paid_at: nil,
      status: 'draft',
      updated_by: nil,
      approved_by: nil,
      reproved_by: nil,
      requested_at: I18n.t('regexp.datetime'),
      approved_at: nil,
      reproved_at: nil,
      reimpursed_at: nil,
      latitude: nil,
      longitude: nil,
      supplier_id: Integer,
      user_id: Integer,
      tag_ids: Array,
      created_at: I18n.t('regexp.datetime'),
      updated_at: I18n.t('regexp.datetime'),
      user: { id: Integer, email: Types::Email, name: String },
      supplier: { id: Integer, name: String },
      tags: [{ id: Integer, name: String }]
    }
  }

  let(:pdf_blob) do
    ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join('spec/fixtures/files/sample.pdf')),
      filename: 'sample.pdf',
      content_type: 'application/pdf'
    )
  end

  let(:image_blob) do
    ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join('spec/fixtures/files/sample.jpeg')),
      filename: 'sample.jpeg',
      content_type: 'image/jpeg'
    )
  end

  let(:valid_pdf_params) { { file_type: 'invoice', file: pdf_blob.signed_id } }
  let(:valid_image_params) { { file_type: 'receipt', file: image_blob.signed_id } }

  describe 'GET #index' do
    it 'returns a success response' do
      refund_request_pattern[:id] = refund_request.id
      pattern                     = { data: [refund_request_pattern] }

      get :index

      expect(response).to be_successful
      expect(response.body).to be_json_as(pattern)
    end

    context 'when supplier_id params is present' do
      let!(:refund_request_unlisted) { create(:refund_request) }
      it 'returns only refund requests having supplier_id' do
        refund_request = create(:refund_request, supplier: create(:supplier))
        refund_request_pattern[:id] = refund_request.id
        pattern = { data: [refund_request_pattern] }

        get :index, params: { supplier_id: refund_request.supplier_id }

        expect(response.body).to be_json_as(pattern)
      end
    end

    context 'when search params is present' do
      let!(:refund_request_unlisted) { create(:refund_request) }

      it 'returns only refund requests having description matche' do
        refund_request = create(:refund_request, description: Faker::Lorem.word.upcase)
        refund_request_pattern[:id] = refund_request.id
        refund_request_pattern[:description] = refund_request.description
        pattern = { data: [refund_request_pattern] }

        get :index, params: { search: refund_request.description }

        expect(response.body).to be_json_as(pattern)
        expect(response).to be_successful
      end

      it 'returns only refund requests having status match' do
        refund_request_status = create(:refund_request, status: RefundRequest::APPROVED_STATUS)
        refund_request_pattern[:id] = refund_request_status.id
        refund_request_pattern[:status] = refund_request_status.status.to_s
        pattern = { data: [refund_request_pattern] }

        get :index, params: { search: refund_request_status.status.to_s }

        expect(response).to be_successful
        expect(response.body).to be_json_as(pattern)
      end

      it 'returns only refund requests having user email match' do
        matching_user = create(:user, email: Faker::Internet.email.upcase)
        refund_request_email = create(:refund_request, user: matching_user)
        refund_request_pattern[:id] = refund_request_email.id
        refund_request_pattern[:user] = {
          id: matching_user.id,
          email: matching_user.email,
          name: matching_user.name
        }
        pattern = { data: [refund_request_pattern] }

        get :index, params: { search: matching_user.email }

        expect(response.body).to be_json_as(pattern)
        expect(response).to be_successful
      end

      it 'returns only refund requests having user name match' do
        matching_user = create(:user, name: Faker::Name.name.upcase)
        refund_request_name = create(:refund_request, user: matching_user)
        refund_request_pattern[:id] = refund_request_name.id
        refund_request_pattern[:user] = {
          id: matching_user.id,
          email: matching_user.email,
          name: matching_user.name
        }
        pattern = { data: [refund_request_pattern] }

        get :index, params: { search: matching_user.name }

        expect(response.body).to be_json_as(pattern)
        expect(response).to be_successful
      end

      it 'returns only refund requests having supplier name match' do
        matching_supplier = create(:supplier, name: Faker::Company.name.upcase)
        refund_request_supplier = create(:refund_request, supplier: matching_supplier)
        refund_request_pattern[:id] = refund_request_supplier.id
        refund_request_pattern[:supplier] = {
          id: matching_supplier.id,
          name: matching_supplier.name
        }
        pattern = { data: [refund_request_pattern] }

        get :index, params: { search: matching_supplier.name }

        expect(response.body).to be_json_as(pattern)
        expect(response).to be_successful
      end

      it 'returns only refund requests having tag name match' do
        refund_request_unlisted = create(:refund_request)
        non_matching_tag = create(:tag, name: Faker::Lorem.word.upcase)
        refund_request_unlisted.tags << non_matching_tag

        matching_tag = create(:tag, name: Faker::Lorem.word.upcase)
        refund_request_tag = create(:refund_request)
        refund_request_tag.tags << matching_tag

        refund_request_pattern[:id] = refund_request_tag.id
        refund_request_pattern[:tags] = [{ id: matching_tag.id, name: matching_tag.name }]
        pattern = { data: [refund_request_pattern] }

        get :index, params: { search: matching_tag.name }

        expect(response.body).to be_json_as(pattern)
        expect(response).to be_successful
      end
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
    context 'with valid params and PDF file' do
      it 'creates a new RefundRequest with attached PDF file' do
        pattern                = refund_request_pattern
        pattern[:user_id]      = @admin_user.id
        pattern[:supplier_id]  = nil
        pattern[:supplier]     = nil
        pattern[:tags]         = []
        pattern[:requested_at] = I18n.t('regexp.datetime')

        post :create, params: valid_attributes.merge(valid_pdf_params)

        expect(response).to have_http_status(:created)
        expect(response.body).to be_json_as(pattern)
        expect(RefundRequest.last.invoice.attached?).to be_truthy
      end
    end

    context 'with valid params and image file' do
      it 'creates a new RefundRequest with attached image file' do
        pattern                = refund_request_pattern
        pattern[:user_id]      = @admin_user.id
        pattern[:supplier_id]  = nil
        pattern[:supplier]     = nil
        pattern[:tags]         = []
        pattern[:requested_at] = I18n.t('regexp.datetime')

        post :create, params: valid_attributes.merge(valid_image_params)

        expect(response.body).to be_json_as(pattern)
        expect(response).to have_http_status(:created)
        expect(RefundRequest.last.receipt.attached?).to be_truthy
      end
    end
  end

  describe 'PUT #update' do
    context 'successfull' do
      it 'when use valid params' do
        refund_request       = create(:refund_request, user: @admin_user)
        pattern              = refund_request_pattern
        pattern[:updated_by] = @admin_user.email

        put :update, params: { **valid_attributes, id: refund_request.id }

        expect(response.body).to be_json_as(pattern)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'failure' do
      context 'when status is draft' do
        let(:refund_request) { create(:refund_request, status: RefundRequest::DRAFT_STATUS) }

        it 'and user is not the owner' do
          pattern                  = { user_id: [I18n.t('errors.refund_request.user.not_owner')] }
          valid_attributes['id']   = refund_request.id

          put :update, params: valid_attributes

          expect(response.body).to be_json_as(pattern)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'when status is requested' do
        let(:refund_request) { create(:refund_request, status: RefundRequest::REQUESTED_STATUS) }
        it 'and user is not a admin' do
          sign_in refund_request.user
          pattern                    = { user_id: [I18n.t('errors.refund_request.user.not_admin')] }
          valid_attributes['id']     = refund_request.id
          valid_attributes['status'] = RefundRequest::APPROVED_STATUS

          put :update, params: valid_attributes

          expect(response.body).to be_json_as(pattern)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested refund_request' do
      delete :destroy, params: { id: refund_request.id }

      expect(response).to have_http_status(:no_content)
      expect(RefundRequest.exists?(refund_request.id)).to be_falsey
    end
  end
end
