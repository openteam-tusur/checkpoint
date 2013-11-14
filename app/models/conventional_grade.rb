class ConventionalGrade < Grade
  enumerize :mark, :in => [0, 2, 3, 4, 5]
end
