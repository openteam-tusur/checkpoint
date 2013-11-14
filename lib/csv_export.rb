require 'csv'

class CsvExport < Struct.new(:exported_object)
  def to_csv(options = {})
    CSV.generate(:col_sep => ';', :force_quotes => true) do |csv|
      csv << ["Предмет: #{exported_object.to_s}"]
      csv << ["Преподаватель: #{exported_object.lecturer.to_s}"]
      csv << ["Группа: #{exported_object.group.to_s}"]
      csv << ['']
      if exported_object.qualification?
        csv << ['0 - не аттестован, 2 - не зачтено, 5 - зачтено']
      else
        csv << ['0 - не аттестован, 2 - неудовлетворительно, 3 - удовлетворительно, 4 - хорошо, 5 - отлично']
      end
      csv << ['']
      csv << csv_header
      exported_object.grades.sort_by{ |g| g.student }.each do |grade|
        info = []
        info << grade.student.to_s
        grade.student.attendances.where(:docket_id => exported_object.id).order(&:kind).each do |attendance|
          info << attendance.to_s
        end
        info << grade.mark
        csv << info
      end
    end
  end

  def name
    Russian.translit([exported_object.abbr, exported_object.lecturer, exported_object.group, (exported_object.kind_text.mb_chars.downcase if exported_object.kind)].compact.join('_').gsub(/\s+/, '_')) + '.csv'
  end

  private

  def csv_header
    header = ['ФИО студента']
    attendances = exported_object.attendances.map(&:kind).uniq
    if attendances.any?
      attendances.each do |attendance|
        header << Attendance.kind_values[attendance]
      end
    end
    header << 'Оценка'
  end
end
