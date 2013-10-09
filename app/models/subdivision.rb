class Subdivision < ActiveRecord::Base
  attr_accessible :abbr, :title

  has_many :dockets
end
