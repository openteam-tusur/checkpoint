class UsersController < ApplicationController
  inherit_resources
  load_and_authorize_resource
  has_scope :by_surname, :default => 1
  actions :index
  layout false
  respond_to :json

  def collection
    super.where("email ILIKE ?", "%#{params[:term]}%" )
  end
end
