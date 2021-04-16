class Contract < ApplicationRecord
  has_many :attachments, as: :attachable, dependent: :restrict_with_error

  validates :name, presence: true
end
