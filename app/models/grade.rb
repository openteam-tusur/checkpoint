class Grade < ActiveRecord::Base
  extend Enumerize
  attr_accessible :mark, :active

  belongs_to :docket
  belongs_to :student

  scope :actived, -> { where(:active => true) }
  scope :inactive, -> { where(:active => false) }

  enumerize :mark, :in => [0, 2, 3, 4, 5]
end
