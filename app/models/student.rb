class Student < Person
  attr_accessible :contingent_id
  has_many :grades
  has_many :dockets, :through => :grades
  has_many :conventional_grades
  has_many :qualification_grades
  has_many :attendances, :order => :kind

  default_scope order('surname ASC')

  def with_active_grades?
    grades.actived.any?
  end
end
