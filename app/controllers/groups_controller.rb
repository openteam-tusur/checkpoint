class GroupsController < ApplicationController
  inherit_resources
  defaults :finder => :find_by_title
  load_and_authorize_resource
  belongs_to :period
  actions :show

  def show
    show! do |format|
      @subdivision = Subdivision.find(params[:subdivision_id])
      @periods = GroupPeriods.new(@group, @period, @subdivision)
      @consolidated_table = ConsolidatedTable.new(@group)
      format.html

      format.pdf do
        pdf_file = ConsolidatedExport.new(@period, @group)
        send_data pdf_file.render,
                   :type => 'text/pdf; charset=cp1251; header=present',
                   :disposition => 'attachment',
                   :filename => pdf_file.filename and return
      end

      format.xlsx do
        xlsx_file = XlsExport.new(@period, @group)
        send_data xlsx_file.render.string,
                   :type => 'text/xlsx; charset=cp1251; header=present',
                   :disposition => 'attachment',
                   :filename => xlsx_file.filename and return
      end
    end
  end
end
