class Attachment < ApplicationRecord
  belongs_to :attachable, polymorphic: true

  has_attached_file :upload,
                    styles: { medium: '300x300>', thumb: '100x100>' },
                    path: ':tenant_directory/:class/:attachment/:hash/:style/:filename',
                    hash_data: ':id/:extension/:fingerprint/:updated_at'

  validates_attachment :upload,
                       presence: true,
                       content_type: { content_type: %w[image/png] },
                       size: { in: 0..100.megabytes }

  # custom interpolation :tenant_directory
  # refer to: config/initializers/paperclip.rb
  def tenant_directory
    'tenant_identifier' # customize with your own multi-tenancy strategy
  end
end
