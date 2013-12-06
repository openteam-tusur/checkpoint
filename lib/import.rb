require 'open-uri'
require 'progress_bar'

class Import
  def initialize(period, group_pattern = '.*')
    @period = period
    @group_pattern = Regexp.new(group_pattern || ".*")
  end

  def subdivision_titles
    @subdivision_titles ||= {
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
      'ВФ' => 'Заочный и вечерний факультет'
    }

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
      student = group.students.find_or_create_by_name_and_surname_and_patronymic_and_contingent_id(
        :name => student_hash['firstname'],
        :surname => student_hash['lastname'],
        :patronymic => student_hash['patronymic'],
        :contingent_id => student_hash['person_id'])
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

  def group_attributes(group)
    student_hash = get_students(group.contingent_number).first
    faculty = student_hash['education']['params']['faculty']
    sub_faculty = student_hash['education']['params']['sub_faculty']

    {:faculty => faculty, :sub_faculty => sub_faculty}
  end

  def sub_abbr(abbr)
    faculty_abbr = {'ЭМиС' => 'ЭМИС', 'ЭКОНОМ' => 'Экономики'}
    faculty_abbr[abbr] || abbr
  end

  def get_subdivision(group, type)
    attributes = group_attributes(group)
    sub = Subdivision.find_by_title(attributes[type]["#{type.to_s}_name"]) || Subdivision.find_by_abbr(sub_abbr(attributes[type]['short_name']))
    unless sub
      sub = Subdivision.create(:abbr => attributes[type]['short_name'], :title => subdivision_titles[attributes[type]['short_name']])
    end
  end

  def reimport_dockets
    file_url = Settings['subdivisions.url']
    response = open(file_url).read
    group_items = JSON.parse response

    group_items.each do |group_item|
      next if !@period.groups.map(&:title).include?(group_item['group']['number'])
      group = @period.groups.find_or_initialize_by_title(group_item['group']['number']).tap do |gr|
        gr.course = group_item['group']['course']
        gr.save
      end
      import_students(group)
      docket_items = @period.exam_session? ? group_item['exam_dockets'] : group_item['checkpoint_dockets']
      create_dockets(docket_items, group)
    end
  end

  def import
    file_url = Settings['subdivisions.url']
    response = open(file_url).read
    group_items = JSON.parse response

    group_items.each do |group_item|
      next if !group_item['group']['number'].match(@group_pattern)
      group = @period.groups.find_or_initialize_by_title(group_item['group']['number']).tap do |gr|
        gr.course = group_item['group']['course']
        gr.save
      end
      import_students(group)
      docket_items = @period.exam_session? ? group_item['exam_dockets'] : group_item['checkpoint_dockets']
      create_dockets(docket_items, group)
    end
  end

  def create_dockets(dockets_hash, group)
    dockets_hash.each do |discipline_hash|
      subdivision = Subdivision.find_or_initialize_by_abbr(discipline_hash['subdivision_abbr']).tap do |sub|
        sub.title = subdivision_titles[discipline_hash['subdivision_abbr']]
        sub.save!
      end
      lecturer = import_lecturer(discipline_hash['lecturer'])

      docket = subdivision.dockets.find_or_create_by_discipline_and_group_id_and_lecturer_id_and_period_id_and_kind(
        :discipline => discipline_hash['discipline'],
        :group_id => group.id,
        :lecturer_id => lecturer ? lecturer.id : Lecturer.find_by_surname('Преподаватель не указан').id,
        :period_id => @period.id,
        :kind => discipline_hash['kind'] || :kt
      )
      docket.update_attributes(
        :faculty_id => get_subdivision(group, :faculty).id,
        :releasing_subdivision_id => get_subdivision(group, :sub_faculty).id,
        :providing_subdivision_id => subdivision.id
      )
      group.students.each do |student|
        create_grades(student, docket)
        create_attendances(student, docket)
      end
    end
  end
end
