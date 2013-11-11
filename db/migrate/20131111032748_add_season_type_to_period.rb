class AddSeasonTypeToPeriod < ActiveRecord::Migration
  def change
    add_column :periods, :season_type, :string
  end
end
