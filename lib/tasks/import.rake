require 'open-uri'
require 'progress_bar'

def import_lecturer(full_name)
  surname, name, patronymic = full_name.try(:split, /\s/)
  return nil unless surname.present?
  Lecturer.find_or_create_by_name_and_patronymic_and_surname(:name => name, :patronymic => patronymic, :surname => surname)
end

def get_students(group_number)
  JSON.parse(open("#{Settings['students.url']}/api/v1/students?group=#{URI.encode(group_number)}").read)
end

def import_groups_and_students(items)
  groups = items.map {|item| item['dockets'].map{|d| d['group']}}.flatten.uniq
  pb = ProgressBar.new(groups.count)
  groups.each do |group|
    group = Group.find_or_create_by_title(group)
    get_students(group.contingent_number).each do |student_hash|
      student = group.students.find_or_create_by_name_and_surname_and_patronymic(
        :name => student_hash['firstname'],
        :surname => student_hash['lastname'],
        :patronymic => student_hash['patronymic'])
    end
    pb.increment!
  end
end

def create_grades(student, docket)
  student.grades.find_or_create_by_docket_id(docket.id)
end

def get_attendance_for(student, discipline)
  JSON.parse(open(URI.encode("#{Settings['attendance.url']}api/attendance?group=#{student.group.title}&student=#{student.full_name}&discipline=#{discipline}")).read)
end

def create_attendances(student, docket)
  attendances = get_attendance_for(student, docket.discipline)
  return if attendances.has_key?('error')
  attendances.each do |discipline_kind, presences|
    student.attendances.find_or_initialize_by_docket_id_and_kind(:docket_id => docket.id, :kind => discipline_kind.to_sym).tap do |attendance|
      attendance.fact = presences['was']
      attendance.total = presences.map{|k,v| v}.reduce(:+)
      attendance.save!
    end
  end
end

desc 'Import data'
task :import => :environment do
  subdivision_titles = {
    'АОИ' => 'Кафедра автоматизации обработки информации',
    'АСУ' => 'Кафедра автоматизированных систем управления',
    'ГП' => 'Кафедра гражданского права',
    'ИП' => 'Кафедра информационного права',
    'ИСР' => 'Кафедра истории и социальной работы',
    'ИЯ' => 'Кафедра иностранных языков',
    'КИБЭВС' => 'Кафедра комплексной информационной безопасности электронно-вычислительных систем',
    'КИПР' => 'Кафедра конструирования и производства радиоаппаратуры',
    'КСУП' => 'Кафедра компьютерных систем в управлении и проектировании',
    'КУДР' => 'Кафедра конструирования узлов и деталей РЭС',
    'Математики' => 'Кафедра математики',
    'МиГ' => 'Кафедра механики и графики',
    'МОТЦ' => 'Кафедра моделирования и основ теории цепей',
    'ОКЮ' => 'Отделение кафедры ЮНЕСКО',
    'ПМиИ' => 'Кафедра прикладной математики и информатики',
    'ПрЭ' => 'Кафедра промышленной электроники',
    'РЗИ' => 'Кафедра радиоэлектроники и защиты информации',
    'РТС' => 'Кафедра радиотехнических систем',
    'РЭТЭМ' => 'Кафедра радиоэлектронных технологий и экологического мониторинга',
    'СА' => 'Кафедра системного анализа',
    'СВЧиКР' => 'Кафедра сверхвысокочастотной и квантовой радиотехники',
    'СРС' => 'Кафедра средств радиосвязи',
    'ТОР' => 'Кафедра телекоммуникаций и основ радиотехники',
    'ТП' => 'Кафедра теории права',
    'ТУ' => 'Кафедра телевидения и управления',
    'УИ' => 'Кафедра управления инновациями',
    'УП' => 'Кафедра уголовного права',
    'ФВиС' => 'Кафедра физвоспитания и спорта',
    'Физ' => 'Кафедра физики',
    'ФиС' => 'Кафедра философии и социологии',
    'ФЭ' => 'Кафедра физической электроники',
    'Экономики' => 'Кафедра экономики',
    'ЭМИС' => 'Кафедра экономической математики, информатики и статистики',
    'ЭП' => 'Кафедра электронных приборов',
    'ЭС' => 'Кафедра электронных систем',
    'ЭСАУ' => 'Кафедра электронных средств автоматизации и управления'
  }
  file_url = Settings['subdivisions.url']
  response = open(file_url).read
  items = JSON.parse response

  import_groups_and_students(items)

  items.each do |item|
    subdivision = Subdivision.find_or_initialize_by_abbr(item['abbr']).tap do |sub|
      sub.title = subdivision_titles[item['abbr']]
      sub.save!
    end

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
