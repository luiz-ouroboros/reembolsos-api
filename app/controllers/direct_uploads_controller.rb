class DirectUploadsController < ActiveStorage::DirectUploadsController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!

  MAX_FILE_SIZE = 5.megabytes
  ALLOWED_CONTENT_TYPES = ['image/png', 'image/jpeg', 'application/pdf']

  def create
    blob_params = params.require(:blob).permit(:filename, :content_type, :byte_size, :checksum, metadata: {})

    if blob_params[:byte_size].to_i > MAX_FILE_SIZE
      render json: { error: "Arquivo maior que o permitido (#{MAX_FILE_SIZE})" }, status: :unprocessable_entity and return
    end

    unless ALLOWED_CONTENT_TYPES.include?(blob_params[:content_type])
      render json: { error: "Tipo de arquivo não permitido" }, status: :unprocessable_entity and return
    end

    super
  end
end
