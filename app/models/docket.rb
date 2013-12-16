class Docket < ActiveRecord::Base
  include DocketSubdivision
  extend Enumerize

  attr_accessible :discipline, :group_id, :lecturer_id, :grades_attributes,
                  :period_id, :kind, :subdivision_id, :releasing_subdivision_id,
                  :providing_subdivision_id, :faculty_id, :discipline_cycle

  belongs_to :faculty,                :class_name => Subdivision
  belongs_to :group
  belongs_to :lecturer
  belongs_to :period
  belongs_to :providing_subdivision,  :class_name => Subdivision
  belongs_to :releasing_subdivision,  :class_name => Subdivision
  belongs_to :subdivision

  validates_presence_of :discipline, :kind, :subdivision_id

  has_many :grades
  has_many :conventional_grades, :dependent => :destroy
  has_many :qualification_grades, :dependent => :destroy
  has_many :attendances, :dependent => :destroy, :order => :kind
  has_many :students, :through => :grades

  alias_attribute :to_s, :discipline

  accepts_nested_attributes_for :grades, :reject_if => :all_blank

  after_save :clear_grades
  after_create :set_subdivisions
  after_create :create_grades

  scope :by_period,           ->(period) { where :period_id => period }
  scope :filled,              ->         { joins(:grades).where("grades.mark is not null AND grades.active = :true OR grades.mark is null AND grades.active != :true", :true => true).uniq }
  scope :with_active_grades,  ->         { joins(:grades).where('grades.active = ?', true).uniq }
  scope :by_kind,             ->(kind)   { where(:kind => kind) }

  enumerize :kind, :in => [:qualification, :diff_qualification, :exam, :kt], :predicates => true, :default => :kt
  enumerize :discipline_cycle, :in => [:general, :gpo, :alternative, :elective], :predicates => true

  def set_subdivisions
    self.update_attributes(:releasing_subdivision_id => get_subdivision(self.group, :sub_faculty).id,
                           :faculty_id => get_subdivision(self.group, :faculty).id)
  end

  def create_grades
    group.students.each do |student|
      if self.qualification?
        self.qualification_grades.find_or_create_by_student_id(:student_id => student.id)
      else
        self.conventional_grades.find_or_create_by_student_id(:student_id => student.id)
      end
    end
  end

  def filled_marks?
    !grades.actived.pluck(:mark).include?(nil)
  end

  def filled?
    filled_marks?
  end

  def examination?
    return true if self.qualification? || self.diff_qualification? || self.exam?
  end

  def abbr_translited
    Russian.translit(self.abbr)
  end

  def kind_translited
    Russian.translit(self.kind_text)
  end

  def abbr
    ignored = %w[при из в и у над без до к на по о от при с]
    vocals = %w[а е ё и о у ы э ю я]
    words = (self.discipline.gsub(/\(.+\)|\/.+\Z|\*|\\.+\Z|:.+\Z|\.|\d+|-/, ' ').gsub(/["',\/]/, '').squish.split(' ') - ignored)

    if words.one?
      word = words.first
      if word.size > 6
        short_word = []
        word.split('').each_with_index do |w, index|
          if index <= 5
            short_word << w
          elsif index > 5 && vocals.include?(short_word.last)
            short_word << w
          else
            return short_word.join
          end
        end
        short_word.join
      else
        word
      end
    else
      words.map{ |w| w.size > 3 ? w.first.mb_chars.upcase : w }.join
    end
  end

private
  def clear_grades
    self.grades.inactive.update_all(:mark => nil)
  end
end
