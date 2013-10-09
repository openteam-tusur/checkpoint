class Docket < ActiveRecord::Base
  attr_accessible :discipline

  belongs_to :group
  belongs_to :lecturer, class_name: Person
  belongs_to :subdivision

  has_many :grades
  has_many :attendances
end
