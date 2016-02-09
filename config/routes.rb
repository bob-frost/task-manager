Rails.application.routes.draw do
  namespace :api do
  end

  scope module: :web do
    root 'tasks#index'

    resources :users, except: [:index, :new] do
      scope module: :users do
        resources :tasks, only: [:index]
      end
    end
    get :signup, to: 'users#new', as: :signup

    get :login, to: 'sessions#new', as: :login
    post :login, to: 'sessions#create'
    delete :logout, to: 'sessions#destroy', as: :logout

    resources :tasks do
      member do
        patch :next_state
      end
    end
  end
end
