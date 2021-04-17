class AddFingerprintToUploadAttachment < ActiveRecord::Migration[6.1]
  def up
    add_column :attachments, :upload_fingerprint, :string
  end

  def down
    remove_column :attachments, :upload_fingerprint
  end
end
