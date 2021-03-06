class DocketsController < ApplicationController
  inherit_resources
  load_and_authorize_resource
  belongs_to :subdivision
  actions :all, :except => [:destroy, :new, :create]
  custom_actions :resource => :import
  has_scope :by_period
  has_scope :editable_unfilled

  def index
    index!{
      @period = Period.find(params[:by_period]) if params[:by_period].present?
    }
  end

  def show
    show! do |format|
      csv_file = CsvExport.new(@docket)
      pdf_file = Pdf.new(@docket)
      format.html
      format.csv { send_data csv_file.to_csv.encode('cp1251', :invalid => :replace, :undef => :replace, :replace => ""),
                                                :type => 'text/csv; charset=cp1251; header=present',
                                                :disposition => 'attachment',
                                                :filename => csv_file.name and return }
      format.pdf { send_data pdf_file.render,
                   :type => 'text/csv; charset=cp1251; header=present',
                   :disposition => 'attachment',
                   :filename => pdf_file.name and return }
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
