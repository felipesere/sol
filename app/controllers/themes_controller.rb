class ThemesController < ApplicationController
  skip_before_action :require_user

  def update
    cookies.permanent[:theme] = params[:theme].presence_in(%w[light dark auto]) || "auto"
    redirect_back_or_to root_path
  end
end
