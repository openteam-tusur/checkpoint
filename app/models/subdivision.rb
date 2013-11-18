class Subdivision < ActiveRecord::Base
  attr_accessible :abbr, :title, :folder_name

  has_many :dockets, :dependent => :destroy, :order => 'discipline ASC'
  has_many :permissions, :as => :context
  has_many :lecturers, :through => :dockets, :uniq => true, :order => 'surname ASC'

  scope :by_abbr, ->(_) { order(:abbr) }
  scope :by_title, ->(_) { order(:title) }

  after_create :set_folder_name

  def to_s
    title || abbr
  end

  def set_folder_name
    self.folder_name = SecureRandom.hex(15)
    save!
  end

  def abbr_translit
    Russian.translit(abbr)
  end

  def filled_dockets(period)
    self.dockets.by_period(period).filled.uniq.count
  end

  def dockets_count(period)
    self.dockets.by_period(period).with_active_grades.uniq.count
  end
end
