class Grade < ActiveRecord::Base
  attr_accessible :brs, :mark

  belongs_to :docket
  belongs_to :student
end
