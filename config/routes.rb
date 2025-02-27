Rails.application.routes.draw do
  devise_for :users,
             controllers: {
               sessions: 'users/sessions',
               registrations: 'users/registrations'
             }

  direct_uploads_route = ActiveStorage.routes_prefix || '/rails/active_storage'
  scope direct_uploads_route do
    post '/direct_uploads', to: 'direct_uploads#create'
  end

  resources :users, only: [:index, :show, :create, :update, :destroy]
  resources :suppliers, only: [:index, :show, :create, :update, :destroy]
  resources :refund_requests, only: [:index, :show, :create, :update, :destroy]
  resources :tags, only: [:index, :show, :create, :update, :destroy]
end
