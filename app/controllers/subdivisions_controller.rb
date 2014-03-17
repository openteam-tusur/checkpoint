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
      @groups = @subdivision.groups
      @periods_with_groups = GroupsByCourses.new(@subdivision).group
      @periods = Period.all.select {|p| can?(:read, p) && @subdivision.dockets.by_period(p.id).any?}
    }
  end
end
