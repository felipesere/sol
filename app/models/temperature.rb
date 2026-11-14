class Temperature < ApplicationRecord
  belongs_to :child
  belongs_to :user

  validates :measured_at, presence: true
  validates :celsius, numericality: { greater_than_or_equal_to: 34, less_than_or_equal_to: 43 }

  scope :newest_first, -> { order(measured_at: :desc) }
end
