class AddFolderNameToSubdivision < ActiveRecord::Migration
  def change
    add_column :subdivisions, :folder_name, :string
    Subdivision.all.each do |subdivision|
      subdivision.update_column(:folder_name, SecureRandom.hex(15))
    end
  end
end
