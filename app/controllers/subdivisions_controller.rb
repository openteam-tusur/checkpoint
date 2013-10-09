class SubdivisionsController < ApplicationController
  inherit_resources
  load_and_authorize_resource
  actions :index, :show
  has_scope :by_abbr, :default => 1
end
