Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'sessions' }

  resources :users, only: [:index, :show, :create, :update, :destroy]
  resources :suppliers, only: [:index, :show, :create, :update, :destroy]
  resources :refund_requests, only: [:index, :show, :create, :update, :destroy]
  resources :tags, only: [:index, :show, :create, :update, :destroy]
end
