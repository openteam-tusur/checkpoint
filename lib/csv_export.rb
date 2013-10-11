require 'csv'

class CsvExport < Struct.new(:exported_object)
  def to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << csv_header
      exported_object.grades.each do |grade|
        info = []
        info << grade.student.to_s
        grade.student.attendances.where(:docket_id => exported_object.id).order(&:kind).each do |attendance|
          info << attendance.to_s
        end
        info << grade.mark << grade.brs
        csv << info
      end
    end
  end

  def name
    [abbr, exported_object.lecturer, exported_object.group].join(', ') + '.csv'
  end

  private

  def csv_header
    header = ['ФИО студента']
    attendances = exported_object.attendances.map(&:kind).uniq
    if attendances.any?
      attendances.each do |attendance|
        header << Attendance.kind_values[attendance]
      end
    end
    header << 'Оценка' << 'БРС'
  end

  def abbr
    ignored = %w[при из в и у над без до к на по о от при с]
    vocals = %w[а е ё и о у ы э ю я]
    words = (exported_object.discipline.gsub(/\(.+\)|\/.+\Z|\*|\\.+\Z|:.+\Z|\.|\d+|-/, ' ').squish.split(' ') - ignored)

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
