class PeriodsController < ApplicationController
  inherit_resources
  load_and_authorize_resource
  actions :all
end
