require 'prawn'
require 'open-uri'
require 'fileutils'
require 'contingent_students'

module ::Prawn
  class Table
    def column_widths
      [20, 180] + (3..cells.row(0).count - 1).map { ((@pdf.bounds.right - 300)/(cells.row(0).count - 2)).to_i } + [100]
    end
  end
end

class Pdf
  def initialize(docket)
    @docket = docket
  end

  def pdf
    @pdf ||= Prawn::Document.new(:page_size => 'A4')
  end

  def render
    generate
    pdf.render
  end

  def render_to_file
    generate
    pdf.render_file(filename)
  end

  def get_directory(dir)
    FileUtils.mkdir_p(dir)
  end

  def filename
    dir = get_directory("#{@docket.period.docket_path}/#{@docket.subdivision.folder_name}/")
    "#{dir.first}#{@docket.group.translited_title}_#{@docket.abbr_translited}_#{@docket.kind_translited}.pdf"
  end

  def name
    Russian.translit([@docket.abbr, @docket.lecturer, @docket.group, @docket.kind_text.mb_chars.downcase].compact.join('_').gsub(/\s+/, '_')) + '.pdf'
  end

  def set_font_style
    pdf.font_families.update 'Times-Roman' => { :normal => "#{Rails.root}/lib/assets/Times-Roman.ttf",
                                                :bold => "#{Rails.root}/lib/assets/Times-Roman-Bold.ttf",
                                                :italic => "#{Rails.root}/lib/assets/Times-Roman-Italic.ttf",
                                                :bold_italic => "#{Rails.root}/lib/assets/Times-Roman-Bold-Italic.ttf"
                                              }
    pdf.font 'Times-Roman', :size => 10
  end

  def tusur_title
    'Томский государственный университет систем управления и радиоэлектроники'
  end

  def get_group_info
    student_hash = ContingentStudents.new(@docket.group).get_students.first
    semestr = student_hash['education']['params']['semestre']
    speciality = student_hash['education']['params']['speciality']['speciality_code']

    { :speciality => speciality, :semestr => semestr }
  end

  def docket_header1
    "Факультет #{@docket.group.faculty}, курс #{@docket.group.course}, семестр #{get_group_info[:semestr]}, группа #{@docket.group.to_s}, специальность #{get_group_info[:speciality]}"
  end

  def lecturer
    if @docket.lecturer.nil? || @docket.lecturer.surname == 'Преподаватель не указан'
      '_' * 15
    else
      @docket.lecturer.to_s
    end
  end

  def docket_header2
    "Кафедра #{@docket.providing_subdivision.abbr}, преподаватель #{lecturer}, дата ________"
  end

  def discipline_header
    "Дисциплина \'#{@docket.to_s}\'"
  end

  def table_header
    header = ['№','Фамилия И.О.','Оценка','Код','Подпись','№ зачетной книжки']
    header.slice!(3) if @docket.qualification?
    header
  end

  def empty_cells
    return 3 if @docket.qualification?
    4
  end

  def table
    [].tap do |arr|
      arr << table_header
      @docket.students.each_with_index do |student, index|
        student_row = [index + 1, student.to_s]
        empty_cells.times {student_row << ''}
        arr << student_row
      end
    end
  end

  def marks_line
    return 'зачтено _____, не зачтено _____, не аттестовано _____' if @docket.qualification?
    'отлично _____, хорошо _____, удовл. _____, неуд. _____, не аттестовано _____'
  end

  def generate
    set_font_style

    pdf.move_down 20
    pdf.text tusur_title, :size => 12, :align => :center
    pdf.move_down 15
    pdf.text I18n.t("docket.kind.#{@docket.kind}").strip, :size => 14, :align => :center, :style => :bold
    pdf.move_down 10
    pdf.stroke_horizontal_rule
    pdf.move_down 7
    pdf.text docket_header1, :size => 12, :align => :left
    pdf.move_down 7
    pdf.stroke_horizontal_rule
    pdf.move_down 10
    pdf.text docket_header2, :size => 12, :align => :left
    pdf.move_down 5
    pdf.text discipline_header, :size => 12, :align => :left
    pdf.move_down 20

    pdf.table(table, :position => :center) do
      row(0).style(:align => :center)
    end
    pdf.move_down 15
    pdf.text marks_line, :size => 12, :align => :center
    pdf.move_down 40
    pdf.text 'Декан факультета _______________, подпись экзаменатора ____________', :size => 12, :align => :center
  end
end
