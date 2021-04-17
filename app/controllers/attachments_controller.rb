class AttachmentsController < ApplicationController
  # POST /attachments
  def create
    @attachment = Attachment.new(attachment_params)

    ::Services::DirectFileUpload.prepare_attachment(
      paperclip_attachment: @attachment.upload,
      upload_key:           params[:upload_key]
    )

    if @attachment.save
      render json: @attachment, status: :created
    else
      render json: @attachment.errors, status: :unprocessable_entity
    end
  end

  private
  def attachment_params
    params.require(:attachment).permit(:attachable_type, :attachable_id)
  end
end
