class Api::PeriodsController < ApplicationController
  respond_to :json, :only => :index

  def index
    @periods = Period.closed_sessions
    respond_with(@periods) do |format|
      format.json { render :json => @periods.to_json(:only => [:id], :methods => [:json_url]) }
    end
  end
end
