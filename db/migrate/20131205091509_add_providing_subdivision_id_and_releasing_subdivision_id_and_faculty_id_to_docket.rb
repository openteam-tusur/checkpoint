class AddProvidingSubdivisionIdAndReleasingSubdivisionIdAndFacultyIdToDocket < ActiveRecord::Migration
  def change
    add_column :dockets, :providing_subdivision_id, :integer
    add_column :dockets, :releasing_subdivision_id, :integer
    add_column :dockets, :faculty_id, :integer
  end
end
