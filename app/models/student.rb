class Student < Person
  has_many :grades
  has_many :attendances, :order => :kind
  
  default_scope order('surname ASC')
end
