class Docket < ActiveRecord::Base
  extend Enumerize

  attr_accessible :discipline, :group_id, :lecturer_id, :grades_attributes, :period_id, :kind

  belongs_to :group
  belongs_to :lecturer
  belongs_to :subdivision
  belongs_to :period

  has_many :grades
  has_many :conventional_grades, :dependent => :destroy
  has_many :qualification_grades, :dependent => :destroy
  has_many :attendances, :dependent => :destroy, :order => :kind
  has_many :students, :through => :grades

  alias_attribute :to_s, :discipline

  accepts_nested_attributes_for :grades, :reject_if => :all_blank

  after_save :clear_grades

  scope :by_period,       ->(period)  { where :period_id => period }
  scope :filled,   ->          { joins(:grades).where('grades.mark is not null AND grades.active = ?', true) }
  scope :with_active_grades, ->          { joins(:grades).where('grades.active = ?', true) }

  enumerize :kind, :in => [:qualification, :diff_qualification, :exam], :predicates => true

  def filled_marks?
    !grades.actived.pluck(:mark).include?(nil)
  end

  def filled?
    filled_marks?
  end

  def abbr
    ignored = %w[при из в и у над без до к на по о от при с]
    vocals = %w[а е ё и о у ы э ю я]
    words = (self.discipline.gsub(/\(.+\)|\/.+\Z|\*|\\.+\Z|:.+\Z|\.|\d+|-/, ' ').gsub(/["',]/, '').squish.split(' ') - ignored)

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
