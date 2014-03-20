class LecturersController < ApplicationController
  inherit_resources
  belongs_to :subdivision, :optional => true
  actions :index, :show
  load_and_authorize_resource

  def index
    index! {
      authorize! :show, @subdivision
    }
  end

  def show
    show!{
      @periods = Period.for_lecturer(@lecturer)
    }
  end
end
