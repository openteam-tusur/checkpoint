require 'contingent_students'

class GroupInit
  def initialize(period, group_number, course)
    @period = period
    @group_number = group_number
    @course = course
  end

  def chair_abbrs
    @chair_abbrs ||= {
      'ЭКОНОМ' => 'Экономики',
      'ЭМиС' => 'ЭМИС'
    }
  end

  def group
    @group ||= @period.groups.find_or_create_by_title(@group_number)
  end

  def init_faculty(abbr)
    Subdivision::Faculty.find_by_abbr(abbr)
  end

  def init_chair(abbr)
    Subdivision::Chair.find_by_abbr(chair_abbrs[abbr] || abbr)
  end

  def prepare_group
    contingent_students = ContingentStudents.new(group)
    first_student = contingent_students.get_students.first
    faculty = init_faculty(first_student['group']['subfaculty']['faculty']['abbr'])
    chair = init_chair(first_student['group']['subfaculty']['abbr'])

    group.update_attributes(:course => @course ? @course : first_student['group']['course'].to_i,
                            :faculty_id => faculty.id,
                            :chair_id => chair.id)
    contingent_students.import_students unless group.students.any?

    group
  end
end
