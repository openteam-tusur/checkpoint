class Period < ActiveRecord::Base
  extend Enumerize
  attr_accessible :ends_at, :kind, :starts_at, :season_type, :graduate

  has_many :dockets, :dependent => :destroy
  has_many :groups, :dependent => :destroy
  has_many :students, :through => :groups
  has_many :lecturers, ->{ uniq  } ,  :through => :dockets

  default_scope order('id DESC')
  scope :semester,        ->                       { where('kind = :kind1 OR kind = :kind2', :kind1 => :kt_1, :kind2 => :kt_2)}
  scope :closed_sessions, ->                       { where('kind = :kind and ends_at < :date', :kind => :exam_session, :date => Time.zone.today) }
  scope :closed_kts,      ->                       { where('kind in (:kind) and ends_at < :date', :kind => [:kt_1, :kt_2], :date => Time.zone.today) }
  scope :actual,          ->                       { where('ends_at >= ?', Time.zone.today + 1) }
  scope :closed,          ->                       { where('ends_at < ?', Time.zone.today + 1) }
  scope :for_subdivision, ->(subdivision)          { joins(:dockets).where('dockets.subdivision_id = ?', subdivision.id).uniq }
  scope :for_lecturer,    ->(lecturer)             { joins(:dockets).where('dockets.lecturer_id = ?', lecturer.id).uniq }
  scope :by_kind,         ->(kind ,season, year)   { where('kind = :kind and season_type = :season_type and starts_at between :start_of_year and :end_of_year',
                                                     :kind => kind, :season_type => season, :start_of_year => "#{year}-01-01".to_date, :end_of_year => "#{year}-12-31".to_date) }

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

  def json_path
    "public/files/api/#{year}/#{self.season_type}/"
  end

  def json_url
    "#{Settings[:app][:url]}files/api/#{year}/#{self.season_type}/period_#{id}.json"
  end

  def title
    "".tap do |s|
      s << "#{self.season_type_text} #{year}, #{self.kind_text.try(:mb_chars).try(:downcase)}"
      s << ', 5 курс' if self.graduate
    end
  end

  def kind_order
    return 1 if kind == 'kt_1'
    return 2 if kind == 'kt_2'
    return 3 if kind == 'exam_session'
  end
end
