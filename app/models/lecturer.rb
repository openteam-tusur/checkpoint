class Lecturer < Person
  has_many :dockets
  has_many :permissions, :as => :context

  def filled_dockets(period)
    self.dockets.by_period(period).filled.uniq.count
  end

  def dockets_count(period)
    self.dockets.by_period(period).with_active_grades.uniq.count
  end
end
