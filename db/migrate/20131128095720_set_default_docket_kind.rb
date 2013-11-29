class SetDefaultDocketKind < ActiveRecord::Migration
  def up
    Docket.where(:kind => nil).update_all(:kind => :kt)
  end

  def down
  end
end
