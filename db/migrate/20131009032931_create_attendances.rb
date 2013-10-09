class CreateAttendances < ActiveRecord::Migration
  def change
    create_table :attendances do |t|
      t.string :kind
      t.integer :fact
      t.integer :total
      t.references :person
      t.references :docket

      t.timestamps
    end
    add_index :attendances, :person_id
    add_index :attendances, :docket_id
  end
end
