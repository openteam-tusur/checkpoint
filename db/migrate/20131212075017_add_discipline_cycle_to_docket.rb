class AddDisciplineCycleToDocket < ActiveRecord::Migration
  def change
    add_column :dockets, :discipline_cycle, :string
  end
end
