module ApplicationHelper
  def clock(time)
    time.in_time_zone.strftime("%H:%M")
  end

  def duration(minutes)
    minutes = [minutes.round, 0].max
    hours, rest = minutes.divmod(60)
    if hours.zero? then "#{rest}m"
    elsif rest.zero? then "#{hours}h"
    else "#{hours}h #{rest}m"
    end
  end

  def ago(time)
    "#{duration((Time.current - time) / 60)} ago"
  end

  def weekday_if_not_today(time)
    day = time.in_time_zone.to_date
    return if day == Time.zone.today

    day == Time.zone.yesterday ? "Yesterday" : time.in_time_zone.strftime("%A")
  end

  def temperature_state(celsius)
    if celsius >= 39 then ["crit", "High fever"]
    elsif celsius >= 38 then ["warn", "Fever"]
    else ["good", "Normal"]
    end
  end

  def dose_state_pill(status)
    case status.state
    when :ok then ["good", "Ready"]
    when :wait then ["warn", "Wait"]
    when :limit then ["crit", "Limit reached"]
    end
  end

  def medicine_style(child, medicine)
    ChartData.style_for(child, medicine)
  end

  def number(value)
    value.to_d.to_s("F").sub(/\.0+\z/, "").sub(/(\.\d*?)0+\z/, '\1')
  end

  def local_input_value(time = Time.current)
    time.in_time_zone.strftime("%Y-%m-%dT%H:%M")
  end

  def next_theme
    { "auto" => "light", "light" => "dark", "dark" => "auto" }.fetch(current_theme)
  end

  def current_theme
    cookies[:theme].presence_in(%w[light dark]) || "auto"
  end
end
