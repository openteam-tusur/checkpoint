class LecturersController < ApplicationController
  inherit_resources
  belongs_to :subdivision
  actions :index, :show

  def show
    show!{
      @period = Period.find(params[:by_period])
      @subdivision = Subdivision.find(params[:subdivision_id])
      @dockets = @lecturer.dockets.where(:subdivision_id => @subdivision.id).where(:period_id => @period.id)
    }
  end
end
