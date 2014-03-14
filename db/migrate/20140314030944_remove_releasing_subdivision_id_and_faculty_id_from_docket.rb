class RemoveReleasingSubdivisionIdAndFacultyIdFromDocket < ActiveRecord::Migration
  def up
    remove_column :dockets, :releasing_subdivision_id
    remove_column :dockets, :faculty_id
  end

  def down
    add_column :dockets, :releasing_subdivision_id, :integer
    add_column :dockets, :faculty_id, :integer
  end
end
