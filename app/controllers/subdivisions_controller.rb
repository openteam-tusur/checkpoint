class SubdivisionsController < ApplicationController
  inherit_resources
  load_and_authorize_resource
  actions :index, :show
  has_scope :by_title, :default => 1

  def show
    show!{
      @periods = Period.all
    }
  end
end
