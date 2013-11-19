class LecturerDocketsController < ApplicationController
  inherit_resources
  defaults :resource_class => Docket, :collection_name => 'dockets', :instance_name => 'docket', :route_instance_name => 'docket'
  belongs_to :lecturer
  actions :all, :except => [:destroy, :new, :create]
  has_scope :by_period
  load_and_authorize_resource :except => [:index]

  def index
    index!{
      @period = Period.find(params[:by_period])
      authorize! :show, @period
    }
  end

end
