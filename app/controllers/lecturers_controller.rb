class LecturersController < ApplicationController
  inherit_resources
  belongs_to :subdivision, :optional => true
  actions :index, :show
  load_and_authorize_resource

  def show
    show!{
      @periods = Period.all
    }
  end
end
