require 'csv'

class CsvExport
  def initialize(docket)
    @docket = docket
  end

  def period
    @period ||= @docket.period
  end

  def to_csv(options = {})
    CSV.generate(:col_sep => ';', :force_quotes => true) do |csv|
      csv << ["#{@docket.period.season_type_text}, #{@docket.period.kind_text.mb_chars.downcase}"]
      csv << ["#{@docket.kind_text}"] if @docket.kind
      csv << ["Предмет: #{@docket.to_s}"]
      csv << ["Преподаватель: #{@docket.lecturer.to_s}"]
      csv << ["Группа: #{@docket.group.to_s}"]
      csv << ['']
      if @docket.qualification?
        csv << ['Оценка: 0 - не аттестован, 2 - не зачтено, 5 - зачтено']
      else
        csv << ['Оценка: 0 - не аттестован, 2 - неудовлетворительно, 3 - удовлетворительно, 4 - хорошо, 5 - отлично']
      end
      csv << ['']
      csv << csv_header
      @docket.grades.sort_by{ |g| g.student }.each do |grade|
        info = []
        info << grade.student.to_s
        grade.student.attendances.where(:docket_id => @docket.id).order(&:kind).each do |attendance|
          info << attendance.to_s
        end
        info << grade.mark
        csv << info
      end
    end
  end

  def get_directory(dir)
    FileUtils.mkdir_p(dir)
  end

  def file_path
    "#{period.docket_path}/#{@docket.subdivision.folder_name}/"
  end

  def to_csv_file
    file = to_csv.encode('cp1251', :invalid => :replace, :undef => :replace, :replace => "")
     File.open("#{get_directory(file_path).first}#{@docket.group.translited_title}_#{@docket.abbr_translited}.csv","w:cp1251") do |f|
       f.write(file)
       f.close
     end
  end

  def name
    Russian.translit([@docket.abbr, @docket.lecturer, @docket.group, (@docket.kind_text.mb_chars.downcase if @docket.kind)].compact.join('_').gsub(/\s+/, '_')) + '.csv'
  end

  private

  def csv_header
    header = ['ФИО студента']
    attendances = @docket.attendances.map(&:kind).uniq
    if attendances.any?
      attendances.each do |attendance|
        header << Attendance.kind_values[attendance]
      end
    end
    header << 'Оценка'
  end
end
