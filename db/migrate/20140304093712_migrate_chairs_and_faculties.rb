class MigrateChairsAndFaculties < ActiveRecord::Migration
  def change
    Subdivision.all.each do |sub|
      if sub.title.match(/факультет/i)
        sub.update_column(:type, 'Subdivision::Faculty')
      else
        sub.update_column(:type, 'Subdivision::Chair')
      end
    end
  end
end
