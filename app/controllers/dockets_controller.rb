class DocketsController < ApplicationController
  inherit_resources
  load_and_authorize_resource
  belongs_to :subdivision
  actions :all, :except => [:index, :destroy, :new, :create]

  def show
    show! do |format|
      filename = [@docket.abbr, @docket.lecturer, @docket.group].join(', ')
      format.html
      format.csv { send_data @docket.to_csv, type: 'text/csv; charset=utf-8; header=present', filename: filename and return }
    end
  end
end
