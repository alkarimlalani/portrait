Portrait::Application.routes.draw do
  resources :sites, only: [:index, :create]
  resources :users

  get 'sites/history', to: 'sites#history'
  get 'sites/search', to: 'sites#search'

  root to: 'home#index'
end
