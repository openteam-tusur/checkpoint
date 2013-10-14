class DeleteBrsFromGrade < ActiveRecord::Migration
  def change
    remove_column :grades, :brs
  end
end
