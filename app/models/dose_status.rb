# Where a medicine stands inside the rolling 24 hour window.
#
#   :ok     can be given now
#   :wait   under the minimum interval since the last dose
#   :limit  the maximum number of doses in 24h has been reached
class DoseStatus
  WINDOW = 24.hours

  attr_reader :medicine, :now

  def initialize(medicine, now: Time.current)
    @medicine = medicine
    @now = now
  end

  def doses_in_window
    @doses_in_window ||= medicine.doses.where("given_at > ? AND given_at <= ?", now - WINDOW, now).order(:given_at).to_a
  end

  def count
    doses_in_window.size
  end

  def remaining
    [medicine.max_doses_per_24h - count, 0].max
  end

  def last_dose
    doses_in_window.last
  end

  def state
    if count >= medicine.max_doses_per_24h then :limit
    elsif now < interval_ends_at then :wait
    else :ok
    end
  end

  def ok? = state == :ok

  # The earliest moment the next dose is allowed.
  def next_allowed_at
    case state
    when :ok then now
    when :wait then interval_ends_at
    when :limit then [interval_ends_at, slot_frees_at].max
    end
  end

  private

  def interval_ends_at
    last_dose ? last_dose.given_at + medicine.min_interval_minutes.minutes : now - 1
  end

  # When the dose that is currently blocking the limit leaves the window.
  def slot_frees_at
    doses_in_window[count - medicine.max_doses_per_24h].given_at + WINDOW
  end
end
