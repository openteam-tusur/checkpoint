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



      result = {}
      Lecturer.select{|l| [5047, 5056, 5129].include? l.id}.each do |lecturer|
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
      end
      puts result
      StatisticExporter.new(result, "export_statistic_lecturers.xlsx").export_to_xlsx
    end
end


private

  def fill_kind(dockets)
    dockets.flat_map(&:grades).inject({}) do |sum, grade|
      sum[grade.to_s] ||= 0
      sum[grade.to_s] += 1
      sum
    end
  end

  def find_semester_and_year(period)
    number_of_semester = period.season_type == 'autumn' ? 1 : 2
    year =  number_of_semester == 2 ? period.year.to_i - 1 : period.year.to_i
    year = "#{year}-#{year + 1}"
    return [year, "#{number_of_semester.to_s} семестр"]
  end

