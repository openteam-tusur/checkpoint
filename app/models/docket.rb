class Docket < ActiveRecord::Base
  attr_accessible :discipline, :group_id, :lecturer_id, :grades_attributes

  belongs_to :group
  belongs_to :lecturer
  belongs_to :subdivision

  has_many :grades, :dependent => :destroy
  has_many :attendances, :dependent => :destroy, :order => :kind
  has_many :students, :through => :grades

  alias_attribute :to_s, :discipline

  accepts_nested_attributes_for :grades

  after_save :clear_grades

  def filled_marks?
    !grades.actived.pluck(:mark).include?(nil)
  end

  def filled?
    filled_marks?
  end

private
  def clear_grades
    self.grades.inactive.update_all(:mark => nil)
  end
end
