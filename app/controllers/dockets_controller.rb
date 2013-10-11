class DocketsController < ApplicationController
  inherit_resources
  load_and_authorize_resource
  belongs_to :subdivision
  actions :all, :except => [:index, :destroy, :new, :create]
  custom_actions :resource => :import

  def show
    show! do |format|
      file = CsvExport.new(@docket)
      format.html
      format.csv { send_data file.to_csv, type: 'text/csv; charset=utf-8; header=present', filename: file.name and return }
    end
  end

  def import
    import!{
      file = params[:import][:file] if params[:import]

      begin
        CsvImport.new(file.tempfile.path, @docket).import
        flash[:notice] = 'Импорт прошел успешно'
      rescue => e
        logger.error "ERROR: #{e}"
        flash[:alert] = 'Во время импорта произошла ошибка или файл неверного формата'
      end

      redirect_to edit_subdivision_docket_path(@subdivision, @docket) and return
    }
  end
end
