class DocketsController < ApplicationController
  inherit_resources
  load_and_authorize_resource
  belongs_to :subdivision
  actions :all, :except => [:destroy, :new, :create]
  custom_actions :resource => :import
  has_scope :by_period

  def index
    index!{
      @period = Period.find(params[:by_period])
      @lecturers = @dockets.flat_map(&:lecturer).uniq.sort_by(&:surname)
    }
  end

  def show
    show! do |format|
      file = CsvExport.new(@docket)
      format.html
      format.csv { send_data file.to_csv.encode('cp1251', :invalid => :replace, :undef => :replace, :replace => ""),
                                                :type => 'text/csv; charset=cp1251; header=present',
                                                :disposition => 'attachment',
                                                :filename => file.name and return }
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
