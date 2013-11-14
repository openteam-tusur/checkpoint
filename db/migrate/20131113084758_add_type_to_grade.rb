class AddTypeToGrade < ActiveRecord::Migration
  def change
    add_column :grades, :type, :string
    Grade.where(:type => nil).map {|g| g.update_column(:type, 'ConventionalGrade')}
  end
end
