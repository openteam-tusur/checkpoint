class Attendance < ActiveRecord::Base
  attr_accessible :fact, :kind, :total

  belongs_to :docket
  belongs_to :student
end
