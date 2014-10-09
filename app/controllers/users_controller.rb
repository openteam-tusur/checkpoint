require 'open-uri'

class UsersController < ApplicationController
  inherit_resources
  load_and_authorize_resource
  has_scope :by_surname, :default => 1, :only => :index
  actions :index
  layout false
  respond_to :json

  def collection
    super.where("email ILIKE ?", "%#{params[:term]}%" )
  end

  def search
    url = Settings['auth_server.users_url'] + "?term=#{params[:term]}"

    result = open(URI.encode(url)).read

    render :json => result
  end
end
