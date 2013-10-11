class AddActiveToGrade < ActiveRecord::Migration
  def change
    add_column :grades, :active, :boolean, :default => true
  end
end
