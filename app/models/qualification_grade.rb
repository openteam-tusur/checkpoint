class QualificationGrade < Grade
  enumerize :mark, :in => [0, 2, 5]
end
