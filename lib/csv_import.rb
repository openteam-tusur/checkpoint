require 'csv'

class CsvImport < Struct.new(:file, :imported_object)
  def import
    prepare_hash.each do |item|
      surname, name, patronymic = item['ФИО студента'].split(' ')
      student = imported_object.students.find_by_name_and_surname_and_patronymic(name, surname, patronymic)
      grade = student.grades.find_or_create_by_docket_id(imported_object.id)
      grade.update_attributes(:mark => item['Оценка'], :active => true)
    end
  end

  def prepare_hash
    csv_data = CSV.read(file, encoding: 'cp1251', :col_sep => ';')
    headers = csv_data.shift(7).last.map {|i| i.strip.to_s }
    string_data = csv_data.map {|row| row.map {|cell| cell.to_s.strip } }
    string_data.map {|row| Hash[*headers.zip(row).flatten] }
  end
end
