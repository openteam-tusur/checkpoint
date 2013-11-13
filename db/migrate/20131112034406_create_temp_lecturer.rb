class CreateTempLecturer < ActiveRecord::Migration
  def change
    lecturer = Lecturer.create(:surname => 'Преподаватель не указан')
    Docket.where(:lecturer_id => nil).map {|d| d.update_column(:lecturer_id, lecturer.id)}
  end
end
