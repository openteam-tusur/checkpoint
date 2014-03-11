class AddFacultyIdAndChairIdToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :faculty_id, :integer
    add_column :groups, :chair_id, :integer
  end
end
