class Medicine < ApplicationRecord
  belongs_to :child
  has_many :doses, dependent: :restrict_with_error

  scope :active, -> { where(active: true) }

  validates :name, presence: true
  validates :dose_amount, numericality: { greater_than: 0 }
  validates :min_interval_minutes, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :max_doses_per_24h, numericality: { only_integer: true, greater_than: 0 }

  def status(now: Time.current)
    DoseStatus.new(self, now: now)
  end
end
