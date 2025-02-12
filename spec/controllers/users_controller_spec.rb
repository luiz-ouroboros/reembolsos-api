require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { build(:user).attributes }
  let(:invalid_attributes) {
    { name: nil, email: nil, role: nil, active: nil }
  }
  let(:user_pattern) {
    {
      id: Integer,
      email: String,
      created_at: I18n.t('regexp.datetime'),
      updated_at: I18n.t('regexp.datetime'),
      name: String,
      role: String,
      active: true,
      created_by: nil,
      updated_by: nil,
    }
  }


  describe 'GET #index' do
    it 'returns a success response' do
      pattern = { data: [user_pattern] }

      get :index

      expect(response).to be_successful
      expect(response.body).to be_json_as(pattern)
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      pattern         = user_pattern
      pattern[:id]    = user.id
      pattern[:email] = user.email

      get :show, params: { id: user.id }

      expect(response).to be_successful
      expect(response.body).to be_json_as(pattern)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new User' do
        pattern         = user_pattern
        pattern[:email] = valid_attributes['email']
        pattern[:name]  = valid_attributes['name']

        post :create, params: valid_attributes

        expect(response).to have_http_status(:created)
        expect(response.body).to be_json_as(pattern)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested user' do
        pattern         = user_pattern
        pattern[:email] = valid_attributes['email']
        pattern[:name]  = valid_attributes['name']

        put :update, params: { **valid_attributes, id: user.id }

        expect(response).to have_http_status(:ok)
        expect(response.body).to be_json_as(pattern)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested user' do
      user_to_delete = User.create!(valid_attributes)

      delete :destroy, params: { id: user_to_delete.id }

      expect(response).to have_http_status(:no_content)
      expect(User.exists?(user_to_delete.id)).to be_falsey
    end
  end
end