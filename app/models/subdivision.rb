class Subdivision < ActiveRecord::Base
  attr_accessible :abbr, :title

  has_many :dockets

  alias_attribute :to_s, :title
end
