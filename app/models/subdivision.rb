class Subdivision < ActiveRecord::Base
  attr_accessible :abbr, :title

  has_many :dockets, :dependent => :destroy, :order => 'discipline ASC'
  has_many :permissions, :as => :context

  scope :by_abbr, ->(_) { order(:abbr) }

  alias_attribute :to_s, :abbr
end
