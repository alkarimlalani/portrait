Portrait::Application.routes.draw do
  resources :sites, only: [:index, :create]
  resources :users

  get 'sites/history', to: 'sites#history'

  root to: 'home#index'
end
