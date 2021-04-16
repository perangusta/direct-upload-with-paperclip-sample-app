class AttachmentsController < ApplicationController
  # POST /attachments
  def create
    @attachment = Attachment.new(attachment_params)

    if @attachment.save
      render json: @attachment, status: :created
    else
      render json: @attachment.errors, status: :unprocessable_entity
    end
  end

  private
  def attachment_params
    params.require(:attachment).permit(
      :attachable_type,
      :attachable_id,
      :upload
    )
  end
end
