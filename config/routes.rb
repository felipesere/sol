Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "login" => "sessions#new", as: :login
  post "session" => "sessions#create", as: :session
  delete "session" => "sessions#destroy"
  match "auth/:provider/callback" => "sessions#omniauth", via: %i[get post]
  get "auth/failure" => "sessions#failure"

  root "dashboard#show"
end
