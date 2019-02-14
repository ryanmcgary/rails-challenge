Rails.application.routes.draw do
  resources :members
  root to: "members#index"
  get '/header_search', to: 'members#header_search', as: :header_search
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
