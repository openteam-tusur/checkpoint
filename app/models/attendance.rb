class Attendance < ActiveRecord::Base
  extend Enumerize
  attr_accessible :fact, :kind, :total

  enumerize :kind, :in => [:lecture, :practice, :laboratory, :research, :design]

  belongs_to :docket
  belongs_to :student
end
