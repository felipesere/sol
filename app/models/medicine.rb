class Medicine < ApplicationRecord
  belongs_to :child
  has_many :doses, dependent: :restrict_with_error

  # as_needed: a ceiling inside a rolling 24h window (paracetamol).
  # scheduled: a target per calendar day, optionally for a fixed course (antibiotics).
  enum :kind, { as_needed: "as_needed", scheduled: "scheduled" }, default: :as_needed

  scope :active, -> { where(active: true) }

  before_validation :start_course, on: :create

  validates :name, presence: true
  validates :dose_amount, numericality: { greater_than: 0 }
  validates :min_interval_minutes, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :max_doses_per_24h, numericality: { only_integer: true, greater_than: 0 }, if: :as_needed?
  validates :doses_per_day, numericality: { only_integer: true, greater_than: 0 }, if: :scheduled?
  validates :course_days, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true, if: :scheduled?

  def status(now: Time.current)
    DoseStatus.new(self, now: now)
  end

  # Doses we aim for (scheduled) or may not exceed (as needed).
  def target
    scheduled? ? doses_per_day : max_doses_per_24h
  end

  def course_day(today = Time.zone.today)
    (today - started_on).to_i + 1 if scheduled? && started_on
  end

  def course_over?(today = Time.zone.today)
    course_days.present? && course_day(today).to_i > course_days
  end

  private

  def start_course
    self.started_on ||= Time.zone.today if scheduled?
  end
end
