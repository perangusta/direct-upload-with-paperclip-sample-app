class Contract < ApplicationRecord
  validates :name, presence: true
end
