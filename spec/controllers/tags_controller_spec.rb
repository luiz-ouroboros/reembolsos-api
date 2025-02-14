require 'rails_helper'

RSpec.describe TagsController, type: :controller do
  let(:tag) { create(:tag) }
  let(:valid_attributes) { build(:tag).attributes }
  let(:tag_pattern) {
    {
      id: Integer,
      name: ::Types::StringUntil255,
      created_at: I18n.t('regexp.datetime'),
      updated_at: I18n.t('regexp.datetime'),
      created_by: ::Types::Email,
      updated_by: nil,
    }
  }

  describe 'GET #index' do
    it 'success and returns a tag' do
      tag_pattern[:id] = tag.id
      pattern          = { data: [tag_pattern] }

      get :index

      expect(response).to be_successful
      expect(response.body).to be_json_as(pattern)
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      pattern         = tag_pattern
      pattern[:id]    = tag.id
      pattern[:name]  = tag.name

      get :show, params: { id: tag.id }

      expect(response).to be_successful
      expect(response.body).to be_json_as(pattern)
    end
  end

  describe 'POST #create' do
    context 'successfull' do
      it 'when use valid params' do
        pattern              = tag_pattern
        pattern[:name]       = valid_attributes['name']
        pattern[:created_by] = @admin_user.email

        post :create, params: valid_attributes

        expect(response).to have_http_status(:created)
        expect(response.body).to be_json_as(pattern)

        tag = Tag.find(body['id'])

        expect(ActionLog.where(recordable: tag).count).to eq(1)
      end
    end

    context 'failure' do
      it 'when name alreaddy exists' do
        pattern                  = { name: [I18n.t('errors.tag.name.unique')] }
        valid_attributes['name'] = tag.name

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
    end
  end

  describe 'PUT #update' do
    context 'successfull' do
      it 'when use valid params' do
        pattern              = tag_pattern
        pattern[:name]       = valid_attributes['name']
        pattern[:updated_by] = @admin_user.email

        put :update, params: { **valid_attributes, id: tag.id }

        expect(response).to have_http_status(:ok)
        expect(response.body).to be_json_as(pattern)

        tag = Tag.find(body['id'])

        expect(ActionLog.where(recordable: tag).count).to eq(1)
      end
    end

    context 'failure' do
      it 'when name alreaddy exists' do
        pattern                  = { name: [I18n.t('errors.tag.name.unique')] }
        valid_attributes['id']   = tag.id
        valid_attributes['name'] = Tag.create!(build(:tag).attributes).name

        put :update, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end

      it 'when id is blank' do
        pattern                = { id: [I18n.t('dry_validation.errors.filled?')] }
        valid_attributes['id'] = ''

        put :update, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end

      it 'when name not send' do
        pattern                = { name: [I18n.t('dry_validation.errors.key?')] }
        valid_attributes['id'] = tag.id
        valid_attributes.delete('name')

        put :update, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end

      it 'when name is blank' do
        pattern                  = { name: [I18n.t('dry_validation.errors.filled?')] }
        valid_attributes['id']   = tag.id
        valid_attributes['name'] = ''

        put :update, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end

      it 'when name greater than 255 characters' do
        pattern                  = { name: [I18n.t('dry_validation.errors.max_size?', num: 255)] }
        valid_attributes['id']   = tag.id
        valid_attributes['name'] = 'a' * 256

        put :update, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'successfull' do
      it 'when use valid params' do
        tag_to_delete = Tag.create!(valid_attributes)

        delete :destroy, params: { id: tag_to_delete.id }

        expect(response).to have_http_status(:no_content)
        expect(Tag.exists?(tag_to_delete.id)).to be_falsey
        expect(ActionLog.where(recordable: tag_to_delete).count).to eq(1)
      end
    end

    context 'failure' do
      it 'when tag has refund_requests' do
        tag_to_delete  = Tag.create!(valid_attributes)
        refund_request = create(:refund_request)
        refund_request.tags << tag_to_delete

        pattern = { error: [I18n.t('errors.tag.refund_request_association')] }

        delete :destroy, params: { id: tag_to_delete.id }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to be_json_as(pattern)
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

      it 'when tag not found' do
        pattern = { error: [I18n.t('errors.not_found')] }

        delete :destroy, params: { id: Tag.count + 1 }

        expect(response).to have_http_status(:not_found)
        expect(response.body).to be_json_as(pattern)
      end
    end
  end
end
