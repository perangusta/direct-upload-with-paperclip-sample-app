class AddUploadToAttachment < ActiveRecord::Migration[6.1]
  def up
    add_attachment :attachments, :upload
  end

  def down
    remove_attachment :attachments, :upload
  end
end
