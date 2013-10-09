class Student < Person
  has_many :grades
  has_many :attendances
end
