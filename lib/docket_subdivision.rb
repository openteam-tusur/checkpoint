require 'open-uri'
require 'contingent_students'

module DocketSubdivision

  def sub_abbr(abbr)
    faculty_abbr = {
    'ЭМиС' => 'ЭМИС',
    'ЭКОНОМ' => 'Экономики'
    }

    faculty_abbr[abbr] || abbr
  end

  def group_attributes(group)
    student_hash = ContingentStudents.new(group).get_students.first
    faculty = student_hash['education']['params']['faculty']
    sub_faculty = student_hash['education']['params']['sub_faculty']

    {:faculty => faculty, :sub_faculty => sub_faculty}
  end

  def get_subdivision(group, type)
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
      'ВФ' => 'Заочный и вечерний факультет'
    }

    attributes = group_attributes(group)
    sub = Subdivision.find_by_title(attributes[type]["#{type.to_s}_name"]) || Subdivision.find_by_abbr(sub_abbr(attributes[type]['short_name']))
    unless sub
      sub = Subdivision.create(:abbr => attributes[type]['short_name'], :title => subdivision_titles[attributes[type]['short_name']])
    end

    sub
  end
end
