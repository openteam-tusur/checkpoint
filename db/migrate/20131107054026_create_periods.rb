class CreatePeriods < ActiveRecord::Migration
  def change
    create_table :periods do |t|
      t.date :starts_at
      t.date :ends_at
      t.string :kind

      t.timestamps
    end
  end
end
