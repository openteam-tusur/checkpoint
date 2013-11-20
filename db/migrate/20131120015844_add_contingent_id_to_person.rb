class AddContingentIdToPerson < ActiveRecord::Migration
  def change
    add_column :people, :contingent_id, :string
  end
end
