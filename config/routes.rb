Checkpoint::Application.routes.draw do
  resources :permissions, :except => [:show, :edit, :update]
  resources :users, :only => [:index]

  root :to => 'application#index'
end
