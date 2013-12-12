class PeriodDocketsController < ApplicationController
  inherit_resources
  defaults :resource_class => Docket, :collection_name => 'dockets', :instance_name => 'docket', :route_instance_name => 'docket'
  belongs_to :period do
    belongs_to :group
  end
  actions :all, :except => [:index]
  load_and_authorize_resource

end
