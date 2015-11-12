require 'progress_bar'

namespace :export_kt do
  desc "Export data for KT and lecturer"
    task :lecturer => :environment do

      dockets = Period.all.inject({}) do |sum, p |
        year, semester = find_semester_and_year p
        sum[year.to_s] ||= {}
        sum[year][semester] ||= {}
        sum[year][semester][p.kind] ||= []
        p.dockets.each{|docket| sum[year][semester][p.kind] << docket }
        sum
      end

      pb = ProgressBar.new(100)
      result = {}
      Lecturer.last(100).each do |lecturer|
        dockets.each do |year, semesters|
          semesters.each do |semester, kinds|
            kinds.each do |kind, docket_array|
              all_dockets = docket_array.select {|docket| docket.lecturer_id == lecturer.id}
              if all_dockets.any?
                result[lecturer] ||= {}
                result[lecturer][year] ||= {}
                result[lecturer][year][semester] ||= {}
                result[lecturer][year][semester][kind] = fill_kind(all_dockets)
              end
            end
          end
        end
        pb.increment!
      end
     StatisticExporter.new(result, "export_statistic_lecturers.xlsx").export_to_xlsx
     puts "Экспорт данных выполнен!"


     #Проверка на корректность данных
     #Экзаменационные сессии
     #Period.where(:id => 33..41).each do |period|
     #  period.dockets.where(lecturer_id: 5047).each do |docket|
     #  puts docket
     #  marks_ary = []
     #  docket.active_grades.each do |grade|
     #    marks_ary << grade
     #  end
     #  puts result_hash = marks_ary.inject(Hash.new(0)){ |sum, key| sum[key.to_s] += 1; sum }
     #
     #  end
     #end
     #
     #КТ
     #year, semester, period_check = find_semester_and_year()
     #puts "Данные на Сидорова: "
     #puts "Учебный год #{year} : #{period_check}"
     #puts "Ведомости: "
     #period_check.dockets.where(lecturer_id: 5047).each do |docket|
     #  puts docket
     #  marks_ary = []
     #  docket.active_grades.each do |grade|
     #    marks_ary << grade
     #  end
     #  puts result_hash = marks_ary.inject(Hash.new(0)){ |sum, key| sum[key.to_s] += 1; sum }
     #end
    end
end


private

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
    year = "#{year}-#{year + 1}"
    season = period.season_type == "autumn" ? "Осенний" : "Весенний"
    return [year, "#{season.to_s} семестр", period]
  end


