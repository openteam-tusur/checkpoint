require 'prawn'
require 'open-uri'
require 'fileutils'
require 'contingent_students'
require 'dockets_grades'
require 'exporters/export'

module ::Prawn
  class Table
    def column_widths
      [20, 180] + (3..cells.row(0).count).map { ((@pdf.bounds.right - 200)/(cells.row(0).count - 2)).to_i }
    end
  end
end

class ConsolidatedExport
  include DocketsGrades
  include Export

  def initialize(period, group)
    @group = group
    @period = period
  end

  def title
    "МИНОБР РОССИИ\nТУСУР"
  end

  def docket_title
    "Успеваемость студентов по результатам #{I18n.t("period.results.kind.#{@period.kind}")} #{I18n.t("period.results.season_type.#{@period.season_type}")}\nпо состоянию на #{Time.now.strftime('%d.%m.%Y')}\nФакультет: #{@group.faculty.abbr}    Курс: #{@group.course}    Группа: #{@group}".mb_chars.upcase
  end

  def table_header
    [].tap do |arr|
      arr <<  '№' << 'ФИО Студента'
      docket_disciplines.each do |disc|
        if @period.not_session?
          arr << { :content => disc.abbr, :colspan => 2 }
        else
          arr << {:content => disc.abbr}
        end
      end
      arr << { :content => 'Среднее значение', :colspan => 2 } if @period.not_session?
    end.flatten
  end

  def table_kt_header
    count = @period.not_session? ? (docket_disciplines.count + 1) : docket_disciplines.count
    [].tap do |arr|
      arr << '' << ''
      (count).times do
        arr << 'КТ 1' << 'КТ 2'
      end
    end
  end

  def table
    [].tap do |arr|
      arr << table_header
      arr << table_kt_header if @period.not_session?
      student_dockets_hash.each_with_index do |student, index|
        row = []
        row << index + 1
        row << student[:student].full_name
        student[:dockets].each do |docket|
          if @period.not_session?
            kt_1 = docket[:grades][:kt_1].present? ? docket[:grades][:kt_1].to_s : 'нет оценки'
            row << kt_1 << docket[:grades][:kt_2].to_s
          else
            row << docket[:grades][:kt_1].to_s
          end
        end
        if @period.not_session?
          average_marks = average_grades(student)
          row << average_marks[:kt_1] << average_marks[:kt_2]
        end
        arr << row
      end
    end
  end

  def abbr_transcrip_table
    [].tap do |arr|
      arr << ['Аббревиатура', 'Расшифровка']
      docket_disciplines.each do |discipline|
        arr << ["#{discipline.abbr}", "#{discipline.discipline}"]
      end
    end
  end

  def set_font_style
    pdf.font_families.update 'Times-Roman' => { :normal => "#{Rails.root}/lib/assets/Times-Roman.ttf",
                                                :bold => "#{Rails.root}/lib/assets/Times-Roman-Bold.ttf",
                                                :italic => "#{Rails.root}/lib/assets/Times-Roman-Italic.ttf",
                                                :bold_italic => "#{Rails.root}/lib/assets/Times-Roman-Bold-Italic.ttf"
                                              }
    pdf.font 'Times-Roman', :size => 8
  end

  def pdf
    @pdf ||= Prawn::Document.new(:page_size => 'A3', :page_layout => :landscape)
  end

  def get_directory(dir)
    FileUtils.mkdir_p(dir)
  end

  def file_path
    dir = get_directory("#{@period.docket_path}/#{subdivision.folder_name}/consolidated/")
    "#{dir.first}"+filename
  end

  def filename
    "#{@group.translited_title}.pdf"
  end

  def render_to_file
    generate
    pdf.render_file(file_path)
  end

  def render
    generate
    pdf.render
  end

  def generate
    set_font_style

    pdf.text_box title, :size => 12, :align => :left, :width => 200, :height => 100
    pdf.text_box docket_title, :at => [pdf.bounds.left + 300, pdf.bounds.top], :size => 12, :align => :center, :width => 750, :height => 100
    pdf.move_down 50
    if @period.not_session?
      pdf.table(table, :position => :left, :cell_style => { :align => :center, :padding => 3, :size => 10 }) do 
        column(1).map {|c| c.style(:align => :left)}
        row(0).style(:align => :center, :font_style => :bold)
        row(1).style(:align => :center, :font_style => :bold)
        row(0).column(0..1).map {|c| c.borders = [:top, :left, :right]}
        row(1).column(0..1).map {|c| c.borders = [:bottom, :left, :right]}
      end
    else
      pdf.table(table, :position => :left, :cell_style => { :align => :center, :padding => 3, :size => 10 }) do 
        column(1).map {|c| c.style(:align => :left)}
        row(0).style(:align => :center, :font_style => :bold)
      end
    end
    pdf.move_down 30
    pdf.text docket_disciplines.map {|d| "#{d.abbr} - #{d.discipline}"}.join(', '), :size => 12, :align => :left
  end
end
