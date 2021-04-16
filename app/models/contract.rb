class Contract < ApplicationRecord
  has_many :attachments, dependent: :restrict_with_error

  validates :name, presence: true
end
