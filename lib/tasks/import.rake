require 'open-uri'
require 'progress_bar'

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
  periods = Period.semester.where('starts_at < :date and ends_at > :date',:date => Time.zone.today)
  if periods.any?
    dockets = Docket.where(:period_id => periods.map(&:id))
    pb = ProgressBar.new(dockets.count)
    dockets.each do |docket|
      docket.group.students.each do |student|
        create_attendances(student, docket)
      end
      pb.increment!
    end
  else
    puts "Ошибка! Не задан период."
  end
end
