# Doses and temperature readings of one child over a rolling 48 hours,
# split at the 24 hour mark.
class Timeline
  Event = Struct.new(:kind, :at, :record, keyword_init: true)

  def initialize(child, now: Time.current)
    @child = child
    @now = now
  end

  def recent
    events.select { |event| event.at > @now - 24.hours }
  end

  def earlier
    events.select { |event| event.at <= @now - 24.hours }
  end

  def events
    @events ||= (doses + temperatures).sort_by(&:at).reverse
  end

  private

  def window
    (@now - 48.hours)..@now
  end

  def doses
    @child.doses.includes(:medicine, :user).where(given_at: window).map { |dose| Event.new(kind: :dose, at: dose.given_at, record: dose) }
  end

  def temperatures
    @child.temperatures.includes(:user).where(measured_at: window).map { |reading| Event.new(kind: :temperature, at: reading.measured_at, record: reading) }
  end
end
