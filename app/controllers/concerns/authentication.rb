module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_user
    helper_method :current_user, :auth_config
  end

  private

  def auth_config
    Rails.configuration.x.auth
  end

  def current_user
    return @current_user if defined?(@current_user)

    user = User.find_by(id: cookies.signed[:user_id])
    user = nil if user && auth_config.household? && !auth_config.household_names.include?(user.name)
    @current_user = user
  end

  def sign_in(user)
    cookies.permanent.signed[:user_id] = { value: user.id, httponly: true, same_site: :lax }
  end

  def sign_out
    cookies.delete(:user_id)
  end

  def require_user
    redirect_to login_path unless current_user
  end
end
