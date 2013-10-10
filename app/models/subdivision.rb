class Subdivision < ActiveRecord::Base
  attr_accessible :abbr, :title

  has_many :dockets, :dependent => :destroy, :order => 'discipline ASC'
  has_many :permissions, :as => :context

  scope :by_abbr, ->(_) { order(:abbr) }
  scope :by_title, ->(_) { order(:title) }

  def to_s
    title || abbr
  end
end
