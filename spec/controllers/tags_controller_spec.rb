require 'rails_helper'

RSpec.describe TagsController, type: :controller do
  let(:tag) { create(:tag) }
  let(:valid_attributes) { build(:tag).attributes }
  let(:invalid_attributes) {
    { name: nil, created_by: nil, updated_by: nil }
  }
  let(:tag_pattern) {
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
      tag_pattern[:id] = tag.id
      pattern          = { data: [tag_pattern] }

      get :index

      expect(response).to be_successful
      expect(response.body).to be_json_as(pattern)
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      pattern      = tag_pattern
      pattern[:id] = tag.id

      get :show, params: { id: tag.id }

      expect(response).to be_successful
      expect(response.body).to be_json_as(pattern)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Tag' do
        pattern        = tag_pattern
        pattern[:name] = valid_attributes['name']

        post :create, params: valid_attributes

        expect(response).to have_http_status(:created)
        expect(response.body).to be_json_as(pattern)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested tag' do
        pattern        = tag_pattern
        pattern[:name] = valid_attributes['name']

        put :update, params: { **valid_attributes, id: tag.id }

        expect(response).to have_http_status(:ok)
        expect(response.body).to be_json_as(pattern)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested tag' do
      tag_to_delete = Tag.create!(valid_attributes)

      delete :destroy, params: { id: tag_to_delete.id }

      expect(response).to have_http_status(:no_content)
      expect(Tag.exists?(tag_to_delete.id)).to be_falsey
    end
  end
end