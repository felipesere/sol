class ApplicationController < ActionController::Base
  include Authentication

  allow_browser versions: :modern
  stale_when_importmap_changes

  around_action :use_browser_time_zone

  private

  # Times are entered and shown on the clock of the browser (set by the timezone Stimulus
  # controller). Without a usable cookie, the configured TZ applies.
  def use_browser_time_zone(&block)
    Time.use_zone(Time.find_zone(cookies[:timezone]) || Time.zone, &block)
  end
end
