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
      :semester => @period.season_type,
      :period_kind => @period.kind,
      :period_starts_at => @period.starts_at,
      :period_ends_at => @period.ends_at,
      :year => @period.year,
      :students => @period.students.map do |student|
        next unless student.with_active_grades?
        {
          :contingent_id => student.contingent_id,
          :group_number => student.group.to_s,
          :group_chair_abbr => student.group.chair.abbr,
          :group_course => student.group.course,
          :disciplines => student.dockets.map do |docket|
            next unless docket.grades.find_by_student_id(student.id).active?
            {
              :discipline => docket.discipline,
              :kind => docket.kind_text,
              :discipline_kind => docket.kind,
              :mark => mark(docket.grades.find_by_student_id(student.id)),
              :mark_value => docket.grades.find_by_student_id(student.id).mark,
              :subdivision_abbr => docket.providing_subdivision.abbr,
              :subdivision_title => docket.providing_subdivision.title,
              :discipline_cycle => docket.discipline_cycle_text,
              :cycle => docket.discipline_cycle,
              :updated_at => docket.grades.find_by_student_id(student.id).updated_at.strftime('%Y-%m-%d'),
              :lecturer => docket.lecturer.present? ? {
                :surname => docket.lecturer.surname,
                :name => docket.lecturer.name,
                :patronymic => docket.lecturer.patronymic
              } : nil
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
    #return if File.size?(filename).to_i > 0
    File.open(filename, 'w') do |f|
      f.write(generate.to_json)
    end
  end
end
