class SubdivisionsController < ApplicationController
  inherit_resources
  load_and_authorize_resource
  actions :index, :show
  has_scope :by_title, :default => 1

  def index
    index! {
      authorize! :manage, Subdivision
    }
  end

  def show
    show!{
      @periods = Period.all.select {|p| can?(:read, p) && @subdivision.dockets.by_period(p.id).any?}
    }
  end
end
