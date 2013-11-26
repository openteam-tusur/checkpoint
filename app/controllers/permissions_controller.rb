class PermissionsController < ApplicationController
  inherit_resources
  load_and_authorize_resource
  has_scope :by_user, :default => 1
  has_scope :by_role, :only => :index, :allow_blank => true
  actions :all, :except => [:show, :edit, :update]
end
