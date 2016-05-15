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

  def progressive?
    alternative = grades.joins(:docket).where("dockets.discipline ilike '%гпо%' or dockets.discipline ilike '%*%'")
    normal = grades.where.not(:id => alternative.pluck(:id))
    return normal.unprogressive.count == 0 if alternative.empty?
    alternative.unprogressive.count < alternative.count && normal.unprogressive.count == 0
  end

  def unprogressive?
    return false if grades.empty?
    line = 0.5
    alternative = grades.joins(:docket).where("dockets.discipline ilike '%гпо%' or dockets.discipline ilike '%*%'")
    normal = grades.where.not(:id => alternative.pluck(:id))
    return normal.unprogressive.count >= grades.count*line if alternative.empty?
    alternative.unprogressive.count >= alternative.count*line && normal.unprogressive.count >= normal.count*line
  end
end
