# Everything the temperature chart needs, as plain JSON-able data.
# Times are minutes relative to now (negative = in the past).
class ChartData
  # Colours and marker shapes handed out to a child's medicines in order.
  STYLES = [
    { color: "--c-para", mark: "diamond", shape: "rectRot" },
    { color: "--c-ibu", mark: "tri", shape: "triangle" },
    { color: "--c-other", mark: "circle", shape: "circle" }
  ].freeze

  def self.style_for(child, medicine)
    index = child.medicines.order(:id).pluck(:id).index(medicine.id) || 0
    STYLES[index % STYLES.size]
  end

  def initialize(child, hours:, now: Time.current)
    @child = child
    @hours = hours
    @now = now
  end

  def as_json(*)
    {
      hours: @hours,
      temperatures: temperatures.map { |t| { x: minutes(t.measured_at), y: t.celsius.to_f, at: t.measured_at.iso8601, by: t.user.name } },
      doses: doses.map do |d|
        { x: minutes(d.given_at), medicine: d.medicine_id, at: d.given_at.iso8601, by: d.user.name, amount: d.amount.to_f, unit: d.medicine.dose_unit }
      end,
      medicines: @child.medicines.order(:id).map do |m|
        style = self.class.style_for(@child, m)
        { id: m.id, name: m.name, color: style[:color], shape: style[:shape] }
      end
    }
  end

  private

  def minutes(time)
    ((time - @now) / 60.0).round(1)
  end

  # A little extra before the window so lines run into the chart edge.
  def since
    @now - (@hours + 3).hours
  end

  def temperatures
    @child.temperatures.includes(:user).where(measured_at: since..@now).order(:measured_at)
  end

  def doses
    @child.doses.includes(:medicine, :user).where(given_at: since..@now).order(:given_at)
  end
end
