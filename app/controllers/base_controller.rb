class BaseController < ApplicationController
  before_action :authenticate_user!
  authorize_resource

  rescue_from CanCan::AccessDenied, with: :unauthorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def process_usecase(usecase, custom_user: current_user, custom_params: params.to_unsafe_h)
    usecase.call(current_user: custom_user, params: custom_params)
      .on_success { |result| yield(result) }
      .on_failure(:validation_error) { |result| render json: result, status: :unprocessable_entity }
  end

  def record_not_found(exception)
    render json: { error: [I18n.t('errors.not_found')] }, status: :not_found
  end

  def unauthorized(exception)
    render json: { error: [I18n.t('errors.unauthorized')] }, status: :forbidden
  end
end
