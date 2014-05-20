class GroupsController < ApplicationController
  inherit_resources
  defaults :finder => :find_by_title
  load_and_authorize_resource
  belongs_to :period
  actions :show

  def show
    show!{
      @subdivision = Subdivision.find(params[:subdivision_id])
      @periods = GroupPeriods.new(@group, @period, @subdivision)
      @consolidated_table = ConsolidatedTable.new(@group)
    }
  end
end
