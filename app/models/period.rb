require 'import'

class Period < ActiveRecord::Base
  extend Enumerize
  attr_accessible :ends_at, :kind, :starts_at, :season_type

  has_many :dockets

  after_create :create_dockets

  enumerize :kind, :in => [:kt_1, :kt_2, :exam_week, :exam_session]
  enumerize :season_type, :in => [:spring, :autumn]

  def create_dockets
    Import.new(self).import
  end

  def year
    self.starts_at.strftime('%Y')
  end

  def timescale
    "Начало: #{self.starts_at.strftime('%d.%m.%Y')}, конец: #{self.ends_at.strftime('%d.%m.%Y')}"
  end

  def docket_path
    "public/grades/#{year}/#{self.season_type}/#{self.kind}"
  end

  def title
    "#{self.season_type_text} #{year}, #{self.kind_text.mb_chars.downcase}"
  end
end
