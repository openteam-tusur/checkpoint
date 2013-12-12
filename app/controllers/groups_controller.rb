class GroupsController < ApplicationController
  inherit_resources
  load_and_authorize_resource
  belongs_to :period
  actions :destroy, :show
end
