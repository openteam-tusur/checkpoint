require 'open-uri'
require 'progress_bar'
require 'contingent_students'

def get_attendance_for(student, discipline)
  JSON.parse(open(URI.encode("#{Settings['attendance.url']}api/attendance?group=#{student.group.title}&student=#{student.full_name}&discipline=#{discipline}")).read)
end

def create_attendances(student, docket)
  attendances = get_attendance_for(student, docket.discipline)
  return if attendances.has_key?('error')
  attendances.each do |discipline_kind, presences|
    student.attendances.find_or_initialize_by_docket_id_and_kind(:docket_id => docket.id, :kind => Attendance.kind_value(discipline_kind).to_s).tap do |attendance|
      attendance.fact = presences['was'].to_i + presences['valid_excuse'].to_i
      attendance.total = presences.map{|k,v| v}.reduce(:+)
      attendance.save!
    end
  end
end

desc 'Import attendances'
task :import_attendances => :environment do
  periods = Period.all
  periods.each do |period|
    if period.actual?
      puts "Импорт успеваемости для #{I18n.t("period.results.kind.#{period.kind}")}, #{I18n.t("period.results.season_type.#{period.season_type}")}, #{period.starts_at.strftime('%Y')}"
      pb = ProgressBar.new(period.dockets.count)
      period.dockets.each do |docket|
        docket.group.students.each do |student|
          create_attendances(student, docket)
        end
        pb.increment!
      end
    end
  end
end

desc 'Synchronize students'
task :sync_students => :environment do
  periods = Period.all
  periods.each do |period|
    if period.actual?
      puts "Импорт студентов для #{I18n.t("period.results.kind.#{period.kind}")}, #{I18n.t("period.results.season_type.#{period.season_type}")}, #{period.starts_at.strftime('%Y')}"
      pb = ProgressBar.new(period.groups.count)
      period.groups.each do |group|
        ContingentStudents.new(group).import_students
        group.dockets.map(&:create_grades)
        pb.increment!
      end
    end
  end
end
