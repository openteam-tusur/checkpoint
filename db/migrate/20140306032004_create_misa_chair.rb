class CreateMisaChair < ActiveRecord::Migration
  def change
    Subdivision::Chair.create(:title => 'Кафедра моделирования и системного анализа', :abbr => 'МиСА')
  end
end
