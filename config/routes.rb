Checkpoint::Application.routes.draw do
  resources :permissions,   :except => [:show, :edit, :update]

  resources :subdivisions,  :only   => [:index, :show] do
    resources :dockets, :except => [:index, :destroy, :new, :create]
  end

  resources :users,         :only   => [:index]

  root :to => 'application#index'
end
