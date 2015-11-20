require 'progress_bar'

desc "Export data for KT and lecturer"
task :export_lecturers_statistic => :environment do

  puts "Подготовка списка периодов"
  pb = ProgressBar.new(Period.count)
  dockets = Period.all.inject({}) do |sum, p |
    year, semester = find_semester_and_year(p)
    sum[year.to_s] ||= {}
    sum[year][semester] ||= {}
    sum[year][semester][p.kind_text] ||= []
    p.dockets.each{|docket| sum[year][semester][p.kind_text] << docket }
    pb.increment!
    sum
  end

  periods_list = {}
  dockets.each do |year, semesters|
    periods_list[year] ||= {}
    semesters.each do |semester, kinds|
        periods_list[year][semester] ||= {}
      kinds.each do |kind, dockets_ary|
        periods_list[year][semester][kind] ||= kind
      end
    end
  end


  puts "Подготовка статистики по преподавателям"
  pb = ProgressBar.new(Lecturer.count)
  result = {}
  Lecturer.order(:surname).each do |lecturer|
    dockets.each do |year, semesters|
      semesters.each do |semester, kinds|
        kinds.each do |kind, docket_array|
          lecturer_dockets = docket_array.select {|docket| docket.lecturer_id == lecturer.id}
          result[lecturer] ||= {}
          result[lecturer][year] ||= {}
          result[lecturer][year][semester] ||= {}
          result[lecturer][year][semester][kind] = fill_kind(lecturer_dockets)
        end
      end
    end
    pb.increment!
  end
  puts "Экспорт данных в xls"
  LecturersStatisticExporter.new(result, periods_list, "export_statistic_lecturers.xlsx").export_to_xlsx
  puts "Экспорт данных выполнен!"

end


def fill_kind(dockets)
  grades_list = dockets.flat_map(&:active_grades).inject({}) do |sum, grade|
    sum[grade.to_s] ||= 0
    sum[grade.to_s] += 1
    sum
  end

  ["-", "2", "3","4", "5", "н/а", "Зачтено", "Не зачтено"].each do |grade|
    grades_list[grade] = 0 unless grades_list[grade]
  end

  grades_list
end

def find_semester_and_year(period)
  number_of_semester = period.season_type == 'autumn' ? 1 : 2
  year =  number_of_semester == 2 ? period.year.to_i - 1 : period.year.to_i
  year = "#{year}-#{year + 1} у.г."
  return [year, period.season_type_text]
end
