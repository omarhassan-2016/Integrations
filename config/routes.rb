Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  get '/auth/google', to: 'auth_session#google_oauth'
  get '/auth/google/callback', to: 'auth_session#google_callback'
  resources :events
  resources :emails
end
