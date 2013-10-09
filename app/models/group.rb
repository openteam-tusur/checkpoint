class Group < ActiveRecord::Base
  attr_accessible :title

  has_many :students, :class_name => Person
  has_many :dockets
end
