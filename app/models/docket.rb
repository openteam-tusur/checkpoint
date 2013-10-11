class Docket < ActiveRecord::Base
  attr_accessible :discipline, :group_id, :lecturer_id, :grades_attributes

  belongs_to :group
  belongs_to :lecturer
  belongs_to :subdivision

  has_many :grades, :dependent => :destroy
  has_many :attendances, :dependent => :destroy, :order => :kind
  has_many :students, :through => :grades

  alias_attribute :to_s, :discipline

  accepts_nested_attributes_for :grades

  def csv_header
    header = ['ФИО студента']
    attendances = self.attendances.map(&:kind).uniq
    if attendances.any?
      attendances.each do |attendance|
        header << Attendance.kind_values[attendance]
      end
    end
    header << 'Оценка' << 'БРС'
  end

  def to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << self.csv_header
      self.grades.each do |grade|
        info = []
        info << grade.student.to_s
        grade.student.attendances.where(:docket_id => self.id).order(&:kind).each do |attendance| 
          info << attendance.to_s
        end
        info << grade.mark << grade.brs
        csv << info
      end
    end
  end

  def abbr
    ignored = %w[при из в и у над без до к на по о от при с]
    vocals = %w[а е ё и о у ы э ю я]
    words = (discipline.gsub(/\(.+\)|\/.+\Z|\*|\\.+\Z|:.+\Z|\.|\d+|-/, ' ').squish.split(' ') - ignored)

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
end
