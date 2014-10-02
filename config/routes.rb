Checkpoint::Application.routes.draw do
  namespace :api do
    resources :periods, :only => :index
  end

  resources :permissions,   :except => [:show, :edit, :update]

  resources :subdivisions,  :only   => [:index, :show] do
    resources :periods, :only => []  do
      resources :groups, :only => [:show]
    end
    resources :lecturers, :only => [:index] do
      resources :permissions, :only => [:new, :create, :destroy], :controller => :lecturer_permissions
    end
    resources :dockets, :except => [:destroy, :new, :create] do
      post :import, :on => :member
    end
  end

  resources :users,         :only   => [:index]
  resources :periods do
    post :import, :on => :member
    post :add_group, :on => :member
    resources :groups, :only => [:destroy, :show], :controller => :period_groups do
      resources :dockets, :except => [:index], :controller => :period_dockets
    end
  end
  resources :lecturers,     :only   => [:show] do
    resources :dockets, :except => [:destroy, :new, :create], :controller => :lecturer_dockets
  end

  mount API => '/'

  root :to => 'application#index'
end
