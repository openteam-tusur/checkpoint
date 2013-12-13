class ContingentStudents
  def initialize(group)
    @group = group
  end

  def get_students
    JSON.parse(open("#{Settings['students.url']}/api/v1/students?group=#{URI.encode(@group.contingent_number)}").read)
  end

  def import_students
    get_students.each do |student_hash|
      student = @group.students.find_or_create_by_name_and_surname_and_patronymic_and_contingent_id(
        :name => student_hash['firstname'],
        :surname => student_hash['lastname'],
        :patronymic => student_hash['patronymic'],
        :contingent_id => student_hash['person_id'])
    end
  end
end
