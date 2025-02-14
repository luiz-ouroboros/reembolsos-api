require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { build(:user).attributes }
  let(:user_pattern) {
    {
      id: Integer,
      email: ::Types::Email,
      created_at: I18n.t('regexp.datetime'),
      updated_at: I18n.t('regexp.datetime'),
      name: ::Types::StringUntil255,
      role: ::Types::Users::Roles,
      active: ::Types::Bool,
      created_by: ::Types::Email,
      updated_by: nil,
    }
  }


  describe 'GET #index' do
    it 'success and returns a user' do
      pattern = { data: [user_pattern] }

      get :index

      expect(response).to be_successful
      expect(response.body).to be_json_as(pattern)
    end

    it 'failure and return status forbidden when user role is not admin' do
      sign_in user

      get :index

      expect(response).to have_http_status(:forbidden)
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

    it 'failure and return status forbidden when user role is not admin' do
      sign_in user

      get :show, params: { id: user.id }

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'POST #create' do
    context 'successfull' do
      it 'when use valid params' do
        pattern         = user_pattern
        pattern[:email] = valid_attributes['email']
        pattern[:name]  = valid_attributes['name']

        post :create, params: valid_attributes

        expect(response).to have_http_status(:created)
        expect(response.body).to be_json_as(pattern)

        user = User.find(body['id'])

        expect(ActionLog.where(recordable: user).count).to eq(1)
      end
    end

    context 'failure' do
      it 'when user role is not admin' do
        sign_in user

        post :create, params: valid_attributes

        expect(response).to have_http_status(:forbidden)
      end

      it 'when email alreaddy exists' do
        pattern = { email: [I18n.t('errors.user.email.unique')] }
        valid_attributes['email'] = user.email

        post :create, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end

      it 'when name not send' do
        pattern = { name: [I18n.t('dry_validation.errors.key?')] }
        valid_attributes.delete('name')

        post :create, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end
      it 'when name is blank' do
        pattern = { name: [I18n.t('dry_validation.errors.filled?')] }
        valid_attributes['name'] = ''

        post :create, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end
      it 'when name greater than 255 characters' do
        pattern = { name: [I18n.t('dry_validation.errors.max_size?', num: 255)] }
        valid_attributes['name'] = 'a' * 256

        post :create, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end

      it 'when email not send' do
        pattern = { email: [I18n.t('dry_validation.errors.key?')] }
        valid_attributes.delete('email')

        post :create, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end
      it 'when email is blank' do
        pattern = { email: [I18n.t('dry_validation.errors.filled?')] }
        valid_attributes['email'] = ''

        post :create, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end
      it 'when email is invalid' do
        pattern = { email: [I18n.t('dry_validation.errors.format?')] }
        valid_attributes['email'] = 'zpto'

        post :create, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end

      it 'when role not send' do
        pattern = { role: [I18n.t('dry_validation.errors.key?')] }
        valid_attributes.delete('role')

        post :create, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end
      it 'when role is blank' do
        pattern = { role: [I18n.t('dry_validation.errors.filled?')] }
        valid_attributes['role'] = ''

        post :create, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end
      it 'when role is invalid' do
        pattern = { role: [I18n.t('dry_validation.errors.inclusion?', list: User::ROLES.join(', '))] }
        valid_attributes['role'] = 'xpto'

        post :create, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end
    end
  end

  describe 'PUT #update' do
    context 'successfull' do
      it 'when use valid params' do
        pattern              = user_pattern
        pattern[:name]       = valid_attributes['name']
        pattern[:updated_by] = @admin_user.email

        put :update, params: { **valid_attributes, id: user.id }

        expect(response).to have_http_status(:ok)
        expect(response.body).to be_json_as(pattern)

        user = User.find(body['id'])

        expect(ActionLog.where(recordable: user).count).to eq(1)
      end
    end

    context 'failure' do
      it 'when user role is not admin' do
        sign_in user

        put :update, params: { **valid_attributes, id: user.id }

        expect(response).to have_http_status(:forbidden)
      end

      it 'when id is blank' do
        pattern = { id: [I18n.t('dry_validation.errors.filled?')] }
        valid_attributes['id'] = ''

        put :update, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end
      it 'when id is invalid' do
        pattern = { id: [I18n.t('dry_validation.errors.int?')] }
        valid_attributes['id'] = 'a'

        put :update, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end

      it 'when name not send' do
        pattern = { name: [I18n.t('dry_validation.errors.key?')] }
        valid_attributes['id'] = user.id
        valid_attributes.delete('name')


        put :update, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end
      it 'when name is blank' do
        pattern = { name: [I18n.t('dry_validation.errors.filled?')] }
        valid_attributes['id'] = user.id
        valid_attributes['name'] = ''

        put :update, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end
      it 'when name greater than 255 characters' do
        pattern = { name: [I18n.t('dry_validation.errors.max_size?', num: 255)] }
        valid_attributes['id'] = user.id
        valid_attributes['name'] = 'a' * 256

        put :update, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end

      it 'when role not send' do
        pattern = { role: [I18n.t('dry_validation.errors.key?')] }
        valid_attributes['id'] = user.id
        valid_attributes.delete('role')

        put :update, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end
      it 'when role is blank' do
        pattern = { role: [I18n.t('dry_validation.errors.filled?')] }
        valid_attributes['id'] = user.id
        valid_attributes['role'] = ''

        put :update, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end
      it 'when role is invalid' do
        pattern = { role: [I18n.t('dry_validation.errors.inclusion?', list: User::ROLES.join(', '))] }
        valid_attributes['id'] = user.id
        valid_attributes['role'] = 'xpto'

        put :update, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end

      it 'when active not send' do
        pattern = { active: [I18n.t('dry_validation.errors.key?')] }
        valid_attributes['id'] = user.id
        valid_attributes.delete('active')

        put :update, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end
      it 'when active is blank' do
        pattern = { active: [I18n.t('dry_validation.errors.filled?')] }
        valid_attributes['id'] = user.id
        valid_attributes['active'] = ''

        put :update, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end
      it 'when active is invalid' do
        pattern = { active: [I18n.t('dry_validation.errors.bool?')] }
        valid_attributes['id'] = user.id
        valid_attributes['active'] = 'xpto'

        put :update, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'successfull' do
      it 'when use valid params' do
        user_to_delete = User.create!(valid_attributes)

        delete :destroy, params: { id: user_to_delete.id }

        expect(response).to have_http_status(:no_content)
        expect(User.exists?(user_to_delete.id)).to be_falsey
        expect(ActionLog.where(recordable: user_to_delete).count).to eq(1)
      end
    end

    context 'failure' do
      it 'when user role is not admin' do
        sign_in user

        delete :destroy, params: { id: user.id }

        expect(response).to have_http_status(:forbidden)
      end

      it 'when id is blank' do
        pattern = { id: [I18n.t('dry_validation.errors.filled?')] }

        delete :destroy, params: { id: '' }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end
      it 'when id is invalid' do
        pattern = { id: [I18n.t('dry_validation.errors.int?')] }

        delete :destroy, params: { id: 'a' }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end
      it 'when user not found' do
        pattern = { error: [I18n.t('errors.not_found')] }

        delete :destroy, params: { id: User.count + 1 }

        expect(response).to have_http_status(:not_found)
        expect(response.body).to be_json_as(pattern)
      end
    end
  end
end
