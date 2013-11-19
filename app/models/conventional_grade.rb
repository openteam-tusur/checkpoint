class ConventionalGrade < Grade
  enumerize :mark, :in => [5, 4, 3, 2, 0]
end
