require 'open-uri'

def import_lecturer(full_name)
  surname, name, patronymic = full_name.try(:split, /\s/)
  return nil unless surname.present?
  Lecturer.find_or_create_by_name_and_patronymic_and_surname(:name => name, :patronymic => patronymic, :surname => surname)
end

def get_students(group_number)
  JSON.parse(open("#{Settings['students.url']}/api/v1/students?group=#{URI.encode(group_number)}").read)
end

def import_groups_and_students(items)
  items.map {|item| item['dockets'].map{|d| d['group']}}.flatten.uniq.each do |group|
    group = Group.find_or_create_by_title(group)
    get_students(group.contingent_number).each do |student_hash|
      student = group.students.find_or_create_by_name_and_surname_and_patronymic(
        :name => student_hash['firstname'],
        :surname => student_hash['lastname'],
        :patronymic => student_hash['patronymic'])
    end
  end
end

def create_grades(student, docket)
  student.grades.find_or_create_by_docket_id(docket.id)
end

def create_attendances(student, docket)
  student.attendances.find_or_create_by_docket_id(docket.id)
end

desc 'Import data'
task :import => :environment do
  file_url = Settings['subdivisions.url']
  request = open(file_url).read
  items = JSON.parse request

  import_groups_and_students(items)

  items.each do |item|
    subdivision = Subdivision.find_or_create_by_abbr(item['abbr'])
    puts "Импорт #{subdivision}"

    item['dockets'].each do |discipline_hash|
      group = Group.find_by_title(discipline_hash['group'])

      lecturer = import_lecturer(discipline_hash['lecture'])

      docket = subdivision.dockets.find_or_create_by_discipline_and_group_id_and_lecturer_id(
        :discipline => discipline_hash['discipline'],
        :group_id => group.id,
        :lecturer_id => lecturer ? lecturer.id : nil
      )
      group.students.each do |student|
        create_grades(student, docket)
        create_attendances(student, docket)
      end
    end
  end

  puts '+--------------------------------------------------+'
  puts '         В следующих группах нет студентов'
  puts Group.select{ |g| g.students.empty? }
  puts '+--------------------------------------------------+'
end
