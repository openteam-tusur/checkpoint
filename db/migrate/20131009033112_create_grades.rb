class CreateGrades < ActiveRecord::Migration
  def change
    create_table :grades do |t|
      t.integer :mark
      t.integer :brs
      t.references :student
      t.references :docket

      t.timestamps
    end
    add_index :grades, :student_id
    add_index :grades, :docket_id
  end
end
