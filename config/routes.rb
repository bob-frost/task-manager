Rails.application.routes.draw do
  namespace :api do
  end

  scope module: :web do
    root 'tasks#index'

    resources :users, except: [:index, :new]
    get :signup, to: 'users#new', as: :signup

    get :login, to: 'sessions#new', as: :login
    post :login, to: 'sessions#create'
    delete :logout, to: 'sessions#destroy', as: :logout

    resources :users, only: [:show]
  end
end
