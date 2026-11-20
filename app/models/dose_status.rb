# Where a medicine stands inside the rolling 24 hour window.
#
#   :ok     can be given now
#   :wait   under the minimum interval since the last dose
#   :limit  the maximum number of doses in 24h (or the daily target of a
#           scheduled medicine) has been reached
#   :finished  the course of a scheduled medicine has run its days
#
# As-needed medicines look at a rolling 24 hours, scheduled ones at today.
class DoseStatus
  WINDOW = 24.hours

  attr_reader :medicine, :now

  def initialize(medicine, now: Time.current)
    @medicine = medicine
    @now = now
  end

  def doses_in_window
    @doses_in_window ||= medicine.doses.where("given_at > ? AND given_at <= ?", window_start, now).order(:given_at).to_a
  end

  def count
    doses_in_window.size
  end

  def remaining
    [medicine.target - count, 0].max
  end

  def last_dose
    @last_dose ||= medicine.scheduled? ? medicine.doses.where("given_at <= ?", now).order(:given_at).last : doses_in_window.last
  end

  def state
    if medicine.course_over?(now.to_date) then :finished
    elsif count >= medicine.target then :limit
    elsif now < interval_ends_at then :wait
    else :ok
    end
  end

  def ok? = state == :ok

  # The earliest moment the next dose is allowed.
  def next_allowed_at
    case state
    when :ok, :finished then now
    when :wait then interval_ends_at
    when :limit then [interval_ends_at, slot_frees_at].max
    end
  end

  private

  # The query is exclusive, so scheduled windows start a second before midnight
  # to count a dose given exactly at 00:00.
  def window_start
    medicine.scheduled? ? now.beginning_of_day - 1 : now - WINDOW
  end

  def interval_ends_at
    last_dose ? last_dose.given_at + medicine.min_interval_minutes.minutes : now - 1
  end

  # When the dose that is currently blocking the limit leaves the window.
  def slot_frees_at
    return now.tomorrow.beginning_of_day if medicine.scheduled?

    doses_in_window[count - medicine.target].given_at + WINDOW
  end
end
