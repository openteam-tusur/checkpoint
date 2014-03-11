class RenameVfToZIVfFaculty < ActiveRecord::Migration
  def up
    Subdivision::Faculty.find_by_abbr('ВФ').update_attribute(:abbr, 'ЗиВФ')
  end

  def down
    Subdivision::Faculty.find_by_abbr('ЗиВФ').update_attribute(:abbr, 'ВФ')
  end
end
