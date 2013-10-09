class CreateDockets < ActiveRecord::Migration
  def change
    create_table :dockets do |t|
      t.string :discipline
      t.references :subdivision
      t.references :group
      t.references :person

      t.timestamps
    end
    add_index :dockets, :subdivision_id
    add_index :dockets, :group_id
    add_index :dockets, :person_id
  end
end
