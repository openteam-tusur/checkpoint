require 'open-uri'

class ContingentStudents
  def initialize(group)
    @group = group
  end

  def get_students
    JSON.parse(open("#{Settings['students.url']}/api/v1/students?group=#{URI.encode(@group.contingent_number)}").read)
  end

  def import_students
    get_students.each do |student_hash|
      student = @group.students.find_by_contingent_id(student_hash['person_id'])
      unless student.present?
        @group.students.create(:name => student_hash['firstname'], :surname => student_hash['lastname'], :patronymic => student_hash['patronymic'], :contingent_id => student_hash['person_id'])
      end
    end
  end
end
