class CreateAttendances < ActiveRecord::Migration
  def change
    create_table :attendances do |t|
      t.string :kind
      t.integer :fact
      t.integer :total
      t.references :student
      t.references :docket

      t.timestamps
    end
    add_index :attendances, :student_id
    add_index :attendances, :docket_id
  end
end
