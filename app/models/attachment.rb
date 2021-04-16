class Attachment < ApplicationRecord
  belongs_to :attachable, polymorphic: true

  has_attached_file :upload,
                    path: ':tenant_directory/:class/:attachment/:hash.:extension',
                    hash_data: ':id/:style/:filename/:updated_at'

  validates_attachment :upload,
                       presence: true,
                       content_type: { content_type: %w[application/pdf] },
                       size: { in: 0..100.megabytes }

  # custom interpolation :tenant_directory
  # refer to: config/initializers/paperclip.rb
  def tenant_directory
    'tenant_identifier'
  end
end
