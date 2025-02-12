require 'rails_helper'

RSpec.describe SuppliersController, type: :controller do
  let(:supplier) { create(:supplier) }
  let(:valid_attributes) { build(:supplier).attributes }
  let(:invalid_attributes) {
    { name: nil, created_by: nil, updated_by: nil }
  }
  let(:supplier_pattern) {
    {
      id: Integer,
      name: String,
      created_by: nil,
      updated_by: nil,
      created_at: I18n.t('regexp.datetime'),
      updated_at: I18n.t('regexp.datetime'),
    }
  }

  describe 'GET #index' do
    it 'returns a success response' do
      supplier_pattern[:id] = supplier.id
      pattern               = { data: [supplier_pattern] }

      get :index

      expect(response).to be_successful
      expect(response.body).to be_json_as(pattern)
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      pattern      = supplier_pattern
      pattern[:id] = supplier.id

      get :show, params: { id: supplier.id }

      expect(response).to be_successful
      expect(response.body).to be_json_as(pattern)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Supplier' do
        pattern        = supplier_pattern
        pattern[:name] = valid_attributes['name']

        post :create, params: valid_attributes

        expect(response).to have_http_status(:created)
        expect(response.body).to be_json_as(pattern)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested supplier' do
        pattern        = supplier_pattern
        pattern[:name] = valid_attributes['name']

        put :update, params: { **valid_attributes, id: supplier.id }

        expect(response).to have_http_status(:ok)
        expect(response.body).to be_json_as(pattern)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested supplier' do
      supplier_to_delete = Supplier.create!(valid_attributes)

      delete :destroy, params: { id: supplier_to_delete.id }

      expect(response).to have_http_status(:no_content)
      expect(Supplier.exists?(supplier_to_delete.id)).to be_falsey
    end
  end
end