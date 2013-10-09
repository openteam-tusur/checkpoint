Checkpoint::Application.routes.draw do
  resources :permissions,   :except => [:show, :edit, :update]

  resources :subdivisions,  :only   => [:index, :show] do
    resources :dockets, :except => [:index, :destroy]
  end

  resources :users,         :only   => [:index]

  root :to => 'application#index'
end
