class Grade < ActiveRecord::Base
  extend Enumerize
  attr_accessible :mark, :active, :student_id

  belongs_to :docket
  belongs_to :student

  scope :actived, -> { where(:active => true) }
  scope :inactive, -> { where(:active => false) }

  scope :filled,   -> { where("mark is not null AND active = :true OR mark is null AND active != :true", :true => true) }
  scope :unfilled, -> { where("mark is null AND active = :true", :true => true) }
  scope :progressive, -> { where("mark in (:marks) or mark is null", :marks => [3,4,5]) }
  scope :unprogressive,   -> { where("mark in (:marks) OR mark is null AND active != :true", :true => true, :marks => [0,1,2]) }

  def to_s
    return '-' unless mark.present?
    return 'н/а' if mark.to_i.zero?

    if self.is_a?(QualificationGrade)
      mark_text
    else
      mark
    end
  end
end
