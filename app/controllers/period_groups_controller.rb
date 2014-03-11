class PeriodGroupsController < ApplicationController
  inherit_resources
  defaults :resource_class => Group, :collection_name => 'groups', :instance_name => 'group', :route_instance_name => 'group'
  load_and_authorize_resource

  belongs_to :period

  actions :destroy, :show
end
