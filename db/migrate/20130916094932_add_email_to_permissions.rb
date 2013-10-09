class AddEmailToPermissions < ActiveRecord::Migration
  def change
    add_column :permissions, :email, :string, :default => nil
  end
end
