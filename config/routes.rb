Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  get '/auth/google', to: 'auth_session#google_oauth'
  get '/auth/zoom', to: 'auth_session#zoom_oauth'
  get '/auth/google/callback', to: 'auth_session#google_callback'
  get '/auth/zoom/callback', to: 'auth_session#zoom_callback'
  resources :events do
    put :sync_event_with_google, on: :member
  end

  resources :emails
end
