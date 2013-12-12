class Period < ActiveRecord::Base
  extend Enumerize
  attr_accessible :ends_at, :kind, :starts_at, :season_type, :graduate

  has_many :dockets, :dependent => :destroy
  has_many :groups, :dependent => :destroy

  default_scope order('id DESC')
  scope :semester, -> {where('kind = :kind1 OR kind = :kind2', :kind1 => :kt_1, :kind2 => :kt_2)}

  enumerize :kind, :in => [:kt_1, :kt_2, :exam_session], :predicates => true
  enumerize :season_type, :in => [:spring, :autumn], :predicates => true

  def to_s
    "#{title} #{timescale}"
  end

  def actual?
    return true if Time.zone.today <= self.ends_at + 1
    false
  end

  def editable?
    Time.zone.today >= starts_at && Time.zone.today <= ends_at
  end

  def not_session?
    return true if self.kt_1? || self.kt_2?
    false
  end

  def not_for_last_course?
    return true if (self.kt_2? && self.autumn?) || self.spring? || (self.exam_session? && !self.graduate)
    false
  end

  def year
    self.starts_at.strftime('%Y')
  end

  def timescale
    "с #{self.starts_at.strftime('%d.%m.%Y')} по #{self.ends_at.strftime('%d.%m.%Y')}"
  end

  def docket_path
    "public/grades/#{year}/#{self.season_type}/#{self.kind}_#{self.id}"
  end

  def title
    "".tap do |s|
      s << "#{self.season_type_text} #{year}, #{self.kind_text.mb_chars.downcase}"
      s << ', 5 курс' if self.graduate
    end
  end
end
