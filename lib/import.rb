require 'open-uri'
require 'progress_bar'

class Import
  def initialize(period)
    @period = period
  end

  def import_lecturer(full_name)
    surname, name, patronymic = full_name.try(:split, /\s/)
    return nil unless surname.present?
    Lecturer.find_or_create_by_name_and_patronymic_and_surname(:name => name, :patronymic => patronymic, :surname => surname)
  end

  def get_students(group_number)
    JSON.parse(open("#{Settings['students.url']}/api/v1/students?group=#{URI.encode(group_number)}").read)
  end

  def import_students(group)
    get_students(group.contingent_number).each do |student_hash|
      student = group.students.find_or_create_by_name_and_surname_and_patronymic(
        :name => student_hash['firstname'],
        :surname => student_hash['lastname'],
        :patronymic => student_hash['patronymic'])
    end
  end

  def create_grades(student, docket)
    if docket.qualification?
      student.qualification_grades.find_or_initialize_by_docket_id(docket.id).tap do |grade|
        grade.save!(:validate => false)
      end
    else
      student.conventional_grades.find_or_initialize_by_docket_id(docket.id).tap do |grade|
        grade.save!(:validate => false)
      end
    end
  end

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

  def import
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
      'ЭСАУ' => 'Кафедра электронных средств автоматизации и управления',
      'РТФ' => 'Радиотехнический факультет',
      'РКФ' => 'Радиоконструкторский факультет',
      'ФЭТ' => 'Факультет электронной техники',
      'ФСУ' => 'Факультет систем управления',
      'ФВС' => 'Факультет вычислительных систем',
      'ГФ' => 'Гуманитарный факультет',
      'ЭФ' => 'Экономический факультет',
      'ФИТ' => 'Факультет инновационных технологий',
      'ЮФ' => 'Юридический факультет',
      'ФМС' => 'Факультет моделирования систем',
      'ВФ' => 'Вечерный факультет'
    }
    file_url = Settings['subdivisions.url']
    response = open(file_url).read
    items = JSON.parse response

    if @period.exam_session?
      subdivision_items = items['exam_session']
    else
      subdivision_items = items['checkpoint']
    end

    subdivision_items.each do |item|
      subdivision = Subdivision.find_or_initialize_by_abbr(item['abbr']).tap do |sub|
        sub.title = subdivision_titles[item['abbr']]
        sub.save!
      end

      puts "Импорт #{subdivision}"

      create_dockets(item['dockets'], subdivision)
    end

    puts '+--------------------------------------------------+'
    puts '         В следующих группах нет студентов'
    puts Group.select{ |g| g.students.empty? }
    puts '+--------------------------------------------------+'
  end

  def create_dockets(dockets_hash, subdivision)
    dockets_hash.each do |discipline_hash|
      group_hash = discipline_hash['group']
      next if group_hash['course'] == 5 && @period.not_for_last_course?
      next if @period.graduate && group_hash['course'] != 5
      group = @period.groups.find_or_create_by_title(group_hash['number']).tap do |g|
        g.course = group_hash['course'].to_i
        g.save!
      end
      import_students(group)

      lecturer = import_lecturer(discipline_hash['lecture'])

      docket = subdivision.dockets.find_or_create_by_discipline_and_group_id_and_lecturer_id_and_period_id(
        :discipline => discipline_hash['discipline'],
        :group_id => group.id,
        :lecturer_id => lecturer ? lecturer.id : Lecturer.find_by_surname('Преподаватель не указан').id,
        :period_id => @period.id,
        :kind => (discipline_hash['kind'] if discipline_hash['kind'])
      )
      group.students.each do |student|
        create_grades(student, docket)
        create_attendances(student, docket)
      end
    end
  end
end
