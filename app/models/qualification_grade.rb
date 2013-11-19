class QualificationGrade < Grade
  enumerize :mark, :in => [5, 2, 0]
end
