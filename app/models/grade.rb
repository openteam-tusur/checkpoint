class Grade < ActiveRecord::Base
  attr_accessible :brs, :mark, :active

  belongs_to :docket
  belongs_to :student

  scope :actived, -> { where(:active => true) }
  validates_presence_of :mark, :brs, :if => :active?
end
