class Grade < ActiveRecord::Base
  attr_accessible :brs, :mark, :active

  belongs_to :docket
  belongs_to :student

  delegate :full_name, :to => :student, :prefix => true
end
