class Grade < ActiveRecord::Base
  extend Enumerize
  attr_accessible :mark, :active, :student_id

  belongs_to :docket
  belongs_to :student

  scope :actived, -> { where(:active => true) }
  scope :inactive, -> { where(:active => false) }

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
