Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "groups#home"

  get "g/:share_token", to: "groups#show", as: :group_calendar
  get "g/:share_token/feed", to: "events#feed", as: :group_feed

  scope "g/:share_token", as: :group do
    resources :people, except: %i[index show]
    resources :availabilities, except: %i[index show]
    resources :events, except: %i[index show]
  end
end
