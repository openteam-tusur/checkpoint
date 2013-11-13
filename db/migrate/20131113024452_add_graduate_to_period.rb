class AddGraduateToPeriod < ActiveRecord::Migration
  def change
    add_column :periods, :graduate, :boolean, default: false
  end
end
