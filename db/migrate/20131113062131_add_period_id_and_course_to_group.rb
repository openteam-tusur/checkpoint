class AddPeriodIdAndCourseToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :course, :integer
    add_column :groups, :period_id, :integer
    add_index :groups, :period_id
  end
end
