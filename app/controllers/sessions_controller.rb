class SessionsController < ApplicationController
  skip_before_action :require_user
  skip_forgery_protection only: :omniauth

  def new
  end

  # Household mode: the person picked their name from the configured list.
  def create
    name = params[:name].to_s
    return redirect_to login_path, alert: "Unknown name" unless auth_config.household_names.include?(name)

    sign_in User.household(name)
    redirect_to root_path
  end

  # OIDC mode: callback from the identity provider.
  def omniauth
    sign_in User.from_oidc(request.env["omniauth.auth"])
    redirect_to root_path
  end

  def failure
    redirect_to login_path, alert: "Sign-in failed: #{params[:message].to_s.humanize}"
  end

  def destroy
    sign_out
    redirect_to login_path
  end
end
