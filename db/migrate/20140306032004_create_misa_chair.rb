class CreateMisaChair < ActiveRecord::Migration
  def change
    Subdivision::Chair.find_or_create_by_title_and_abbr(:title => 'Кафедра моделирования и системного анализа', :abbr => 'МиСА')
  end
end
