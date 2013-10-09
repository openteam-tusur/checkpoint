class DocketsController < ApplicationController
  inherit_resources
  load_and_authorize_resource
  actions :all, :except => [:index, :destroy]
end
