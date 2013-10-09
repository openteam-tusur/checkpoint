class CreateSubdivisions < ActiveRecord::Migration
  def change
    create_table :subdivisions do |t|
      t.string :title
      t.string :abbr

      t.timestamps
    end
  end
end
