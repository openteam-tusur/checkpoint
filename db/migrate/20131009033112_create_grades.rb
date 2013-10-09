class CreateGrades < ActiveRecord::Migration
  def change
    create_table :grades do |t|
      t.integer :mark
      t.integer :brs
      t.references :person
      t.references :docket

      t.timestamps
    end
    add_index :grades, :person_id
    add_index :grades, :docket_id
  end
end
