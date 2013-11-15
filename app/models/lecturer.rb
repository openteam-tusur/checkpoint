class Lecturer < Person
  has_many :dockets
  has_many :permissions, :as => :context
end
