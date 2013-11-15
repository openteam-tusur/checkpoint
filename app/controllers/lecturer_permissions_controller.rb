class LecturerPermissionsController < ApplicationController
  inherit_resources
  defaults :resource_class => Permission, :collection_name => 'permissions', :instance_name => 'permission'
  belongs_to :subdivision do
    belongs_to :lecturer
  end
  load_and_authorize_resource :subdivision
  actions :all, :only => [:new, :create, :destroy]

  protected
  def smart_collection_url
    subdivision_lecturers_path(@subdivision)
  end
end
