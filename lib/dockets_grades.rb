module DocketsGrades
  def student_dockets_hash
    dockets_hash = []
    @group.students.map do |student|
      dockets_hash << {
        :student => student,
        :dockets => dockets_array(student)
      }
    end

    dockets_hash
  end

  def dockets_array(student)
    [].tap do |arr|
      ['kt', 'qualification', 'diff_qualification', 'exam'].each do |kind|
        student.dockets.by_kind(kind).sort_by(&:discipline).map do |docket|
          arr << {
            :docket => docket,
            :grades => if previous_group
                         get_grades_with_previous_group(docket, student)
                       else
                         get_grades(docket, student)
                       end
          }
        end
      end
    end
  end

  def get_grades_with_previous_group(docket, student)
    {
      :kt_2 => docket.grades.find_by_student_id(student.id),
      :kt_1 => get_prev_grade(docket, student)
    }
  end

  def get_prev_grade(docket, student)
    prev_student = previous_group.students.find_by_name_and_surname(student.name, student.surname)
    return nil unless prev_student
    prev_docket = previous_period.dockets.find_by_discipline_and_group_id(docket.discipline, previous_group.id)
    return nil unless prev_docket
    prev_docket.grades.find_by_student_id(prev_student.id)
  end

  def get_grades(docket, student)
    { :kt_1 => docket.grades.find_by_student_id(student.id) }
  end

  def average_grades(student)
    kt1 = student[:dockets].map {|d| d[:grades]}.map {|d| d[:kt_1]}.compact
    kt2 = student[:dockets].map {|d| d[:grades]}.map {|d| d[:kt_2]}.compact

    {:kt_1 => average_mark(kt1), :kt_2 => (@period.kt_1? ? '' : average_mark(kt2))}
  end

  def average_mark(grades)
    count = 0
    total = 0
    grades.each do |grade|
      if grade.mark
        total += grade.mark.to_i
        count += 1
      end
    end

    return '-' if count == 0
    (total / count.to_f).round(2)
  end

  def docket_disciplines
    student_dockets_hash.first[:dockets].map {|d| d[:docket]}
  end
end
