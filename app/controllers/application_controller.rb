class ApplicationController < ActionController::API
  rescue_from CanCan::AccessDenied, with: :unauthorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found(exception)
    render json: { error: [I18n.t('errors.not_found')] }, status: :not_found
  end

  def unauthorized(exception)
    render json: { error: [I18n.t('errors.unauthorized')] }, status: :forbidden
  end
end
