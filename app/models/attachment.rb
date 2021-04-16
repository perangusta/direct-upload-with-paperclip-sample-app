class Attachment < ApplicationRecord
  belongs_to :attachable, polymorphic: true

  has_attached_file :upload
  validates_attachment :upload,
                       presence: true,
                       content_type: { content_type: %w[application/pdf] },
                       size: { in: 0..100.megabytes }
end
