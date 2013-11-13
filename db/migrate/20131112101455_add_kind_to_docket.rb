class AddKindToDocket < ActiveRecord::Migration
  def change
    add_column :dockets, :kind, :string
  end
end
