class DirectFileUploadsController < ApplicationController
  # POST /direct_file_uploads
  def create
    presigned_url_settings =
      ::Services::DirectFileUpload.create_presigned_url(
        file_params: params[:file]
      )

    render json: presigned_url_settings, status: :created
  end
end
