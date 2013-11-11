class AddPeriodReferencesToDocket < ActiveRecord::Migration
  def change
    add_column :dockets, :period_id, :integer
    add_index :dockets, :period_id
  end
end
