class AddTypeToSubdivision < ActiveRecord::Migration
  def change
    add_column :subdivisions, :type, :string
  end
end
