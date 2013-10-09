class SubdivisionsController < ApplicationController
  inherit_resources
  load_and_authorize_resource
  actions :index, :show
end
