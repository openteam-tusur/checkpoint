require 'csv'

desc "Export KT statistics"
task :export_kt_statistic => :environment do
  period = Period.find(ENV['period'])
  CSV.open(Rails.root + "tmp/statistic_#{period.id}.csv", "wb") do |csv|
    csv << ['Сведения по заполняемости в разрезе обеспечиваемых кафдр']
    csv << ['Кафедра', 'Количество ведомостей', 'Заполненных', 'Частично заполненных', 'Незаполненных']
    period.dockets.group_by(&:providing_subdivision).each do |subdivision, dockets|
      csv << [
        "#{subdivision.title} (#{subdivision.abbr})",
        dockets.count,
        dockets.select {|d| d.grades.count == d.grades.filled.count }.count,
        dockets.select {|d| d.grades.filled.count > 0 && d.grades.unfilled.count > 0 }.count,
        dockets.select {|d| d.grades.filled.count == 0 && d.grades.unfilled.count > 0 }.count
      ]
    end

    csv << ['Сведения по заполняемости в разрезе факультетов']
    csv << ['Факультет', 'Количество ведомостей', 'Заполненных', 'Частично заполненных', 'Незаполненных']
    period.groups.group_by(&:faculty).each do |faculty, groups|
      dockets = period.dockets.where(:group_id => groups.map(&:id))
      csv << [
        "#{faculty.title} (#{faculty.abbr})",
        dockets.count,
        dockets.select {|d| d.grades.count == d.grades.filled.count }.count,
        dockets.select {|d| d.grades.filled.count > 0 && d.grades.unfilled.count > 0 }.count,
        dockets.select {|d| d.grades.filled.count == 0 && d.grades.unfilled.count > 0 }.count
      ]
    end

    csv << ['Абсолютная успеваемость студентов по курсам']
    csv << ['Факультет', '1', '2', '3', '4', '5', '6']
    period.groups.group_by(&:faculty).each do |faculty, groups|
      progress_stat = ["#{faculty.title} (#{faculty.abbr})"]
      [1,2,3,4,5,6].each do |course|
        groups_at_course = groups.select {|g| g.course == course}
        students = groups_at_course.flat_map(&:students)
        progressive_students = students.select { |s| s.grades.count == s.grades.progressive.count }
        progress_stat << (students.count > 0 ? (progressive_students.count.to_f/students.count)*100 : 0)
      end
      csv << progress_stat
    end

    csv << ['Процент с неудовлетворительными оценками больше половины']
    csv << ['Факультет', '1', '2', '3', '4', '5', '6']
    period.groups.group_by(&:faculty).each do |faculty, groups|
      progress_stat = ["#{faculty.title} (#{faculty.abbr})"]
      [1,2,3,4,5,6].each do |course|
        groups_at_course = groups.select {|g| g.course == course}
        students = groups_at_course.flat_map(&:students)
        unprogressive_students = students.select { |s| s.grades.count < s.grades.unprogressive.count*2 }
        progress_stat << (students.count > 0 ? (unprogressive_students.count.to_f/students.count)*100 : 0)
      end
      csv << progress_stat
    end
  end
end
