require 'fileutils'
require 'json'

class JsonExport
  def initialize(period)
    @period = period
  end

  def generate
    json_hash = []
    json_hash << {
      :id => @period.id,
      :kind => @period.season_type_text,
      :year => @period.year,
      :students => @period.students.map do |student|
        next unless student.with_active_grades?
        {
          :contingent_id => student.contingent_id,
          :group_number => student.group.to_s,
          :disciplines => student.dockets.map do |docket|
            next unless docket.grades.find_by_student_id(student.id).active?
            {
              :discipline => docket.discipline,
              :kind => docket.kind_text,
              :mark => mark(docket.grades.find_by_student_id(student.id)),
              :subdivision_abbr => docket.providing_subdivision.abbr,
              :subdivision_title => docket.providing_subdivision.title,
              :discipline_cycle => docket.discipline_cycle_text,
              :updated_at => docket.grades.find_by_student_id(student.id).updated_at.strftime('%Y-%m-%d')
            }
          end.compact
        }
      end.compact
    }
  end

  def mark(grade)
    return 'н/а' if grade.to_s == '-'
    grade.to_s
  end

  def get_directory(path)
    FileUtils.mkdir_p(path)
  end

  def filename
    "#{get_directory(@period.json_path).first}period_#{@period.id}.json"
  end

  def to_file
    File.open("#{filename}", 'w') do |f|
      f.write(generate.to_json)
    end
  end
end
