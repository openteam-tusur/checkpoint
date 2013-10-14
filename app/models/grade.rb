class Grade < ActiveRecord::Base
  attr_accessible :mark, :active

  belongs_to :docket
  belongs_to :student

  scope :actived, -> { where(:active => true) }
  scope :inactive, -> { where(:active => false) }
  validates_presence_of :mark, :if => :active?
end
