class Person < ActiveRecord::Base
  belongs_to :group
  attr_accessible :name, :patronymic, :surname, :type
end
