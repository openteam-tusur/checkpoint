require 'contingent_students'

class GroupInit
  def initialize(period, group_number, course)
    @period = period
    @group_number = group_number
    @course = course
  end

  def group
    @group ||= @period.groups.find_or_create_by_title(@group_number)
  end

  def prepare_group
    contingent_students = ContingentStudents.new(group)
    first_student = contingent_students.get_students.first

    group.update_attributes(:course => @course ? @course : first_student['group']['course'].to_i)
    contingent_students.import_students unless group.students.any?

    group
  end
end
