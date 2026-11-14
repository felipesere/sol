Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "login" => "sessions#new", as: :login
  post "session" => "sessions#create", as: :session
  delete "session" => "sessions#destroy"
  match "auth/:provider/callback" => "sessions#omniauth", via: %i[get post]
  get "auth/failure" => "sessions#failure"

  patch "theme" => "themes#update", as: :theme

  resources :children, except: :destroy do
    resources :doses, except: %i[index show]
    resources :temperatures, except: %i[index show]
    resources :medicines, except: %i[show destroy]
  end

  root "children#index"
end
