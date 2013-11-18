require 'open-uri'
require 'axlsx'
require 'fileutils'
require 'progress_bar'

class XlsExport

  def initialize(period)
    @faculty_abbr = {
      'ЭМиС' => 'ЭМИС',
      'ЭКОНОМ' => 'Экономики'
    }
    @period = period
    @previous_period = Period.where(:kind => :kt_1, :season_type => @period.season_type).where('id < ?', @period.id).order('id DESC').select {|p| p.starts_at.strftime('%Y') == @period.starts_at.strftime('%Y')}.first
  end

  def get_students(group_number)
    JSON.parse(open("#{Settings['students.url']}/api/v1/students?group=#{URI.encode(group_number)}").read)
  end

  def group_attributes(group_number)
    student_hash = get_students(group_number).first
    faculty = student_hash['education']['params']['faculty']['short_name']
    sub_faculty = student_hash['education']['params']['sub_faculty']
    course = student_hash['education']['params']['course']

    {:faculty => faculty, :sub_faculty => sub_faculty, :course => course}
  end

  def get_directory(dir)
    FileUtils.mkdir_p(dir)
  end

  def sub_abbr(abbr)
    @faculty_abbr[abbr] || abbr
  end

  def get_prev_grade(docket, student, previous_group)
    prev_student = previous_group.students.find_by_name_and_surname(student.name, student.surname)
    return nil unless prev_student
    prev_docket = @previous_period.dockets.find_by_discipline_and_group_id(docket.discipline, previous_group.id)
    return nil unless prev_docket
    prev_docket.grades.find_by_student_id(prev_student.id)
  end

  def get_grades(docket, student, previous_group = nil)
      if previous_group
        {
          :kt_2 => docket.grades.find_by_student_id(student.id),
          :kt_1 => get_prev_grade(docket, student, previous_group)
        }
      else
        { :kt_1 => docket.grades.find_by_student_id(student.id) }
      end
  end

  def student_dockets_hash(current_group, previous_group = nil)
    dockets_hash = []
    current_group.students.map do |student|
      dockets_hash << {
        :student => student,
        :dockets => student.dockets.sort_by(&:discipline).map do |docket|
          {
            :docket => docket,
            :grades => get_grades(docket, student, previous_group)
          }
        end
      }
    end
    dockets_hash
  end

  def to_xls(group)
    previous_group = @previous_period.groups.find_by_title(group.title) if @previous_period
    attributes = group_attributes(group.contingent_number)
    subdivision = Subdivision.find_by_title(attributes[:sub_faculty]['sub_faculty_name']) || Subdivision.find_by_abbr(sub_abbr(attributes[:sub_faculty]['short_name']))
    student_hashes = if @period.kt_2? 
                        student_dockets_hash(group, previous_group)
                      else
                        student_dockets_hash(group)
                      end
    folder_name = subdivision.folder_name
    dir = "#{@period.docket_path}/#{folder_name}/"

    package = Axlsx::Package.new
    wb = package.workbook
    wb.styles do |s|
      center_align = { :horizontal => :center,
                    :vertical => :center,
                    :wrap_text => true}
      left_align = { :horizontal => :left,
                     :vertical => :center,
                     :wrap_text => true}
      border1 = { :style => :medium, :color => "00" }
      border2 = { :style => :medium, :color => "00", :edges => [:left, :right, :top] }
      border3 = { :style => :medium, :color => "00", :edges => [:left, :right, :bottom] }
      wrap_text = s.add_style :b => true,
        :sz => 14,
        :border => border1,
        :alignment => center_align
      wrap_text2 = s.add_style :b => true,
        :sz => 14,
        :border => border2,
        :alignment => center_align
      wrap_text3 = s.add_style :b => true,
        :sz => 14,
        :border => border3,
        :alignment => center_align
      normal_text  = s.add_style :sz => 14,
        :border => { :style => :thin, :color => "00" },
        :alignment => center_align
      normal_without_border = s.add_style :sz => 14,
        :alignment => center_align
      left_align_text = s.add_style :sz => 14,
        :border => { :style => :thin, :color => "00" },
        :alignment => left_align
      left_align_without_border = s.add_style :sz => 14,
        :alignment => left_align

      page_setup = {:fit_to_width => 1, :orientation => :landscape}
      wb.add_worksheet(:name => group.title, :page_setup => page_setup) do |sheet|
        info = []
        info << "МИНОБР РОССИИ\nТУСУР" << ''
        info << "Успеваемость студентов по результатам #{I18n.t("period.results.kind.#{@period.kind}")} #{I18n.t("period.results.season_type.#{@period.season_type}")}\nпо состоянию на #{Time.now.strftime('%d.%m.%Y')}\nФакультет: #{attributes[:faculty]}    Курс: #{attributes[:course]}    Группа: #{group}".mb_chars.upcase
        (group.dockets.count - 1).times { info << '' }
        sheet.add_row info, style: normal_without_border, height: 80
        sheet.merge_cells sheet.rows.first.cells[0..1]
        sheet.merge_cells sheet.rows.first.cells[2..-1]
        header = []
        header << '№' << 'ФИО Студента'
        dockets = student_hashes.first[:dockets].map {|d| d[:docket]}

        if @period.kt_2?
          dockets.each do |docket|
            header << docket.abbr << ''
          end
          h_row = sheet.add_row header, style: wrap_text
          h_row.cells.each_with_index do |cell, index|
            if index > 1 && index % 2 == 0
              sheet.merge_cells h_row.cells[index..index + 1]
            end
          end

          periods_header = []
          periods_header << '' << ''
          dockets.count.times do
            periods_header << 'КТ 1' << 'КТ 2'
          end
          sheet.add_row periods_header, style: wrap_text
        else
          header += dockets.map(&:abbr)
          h_row = sheet.add_row header, style: wrap_text
        end

        student_hashes.each_with_index do |student, index|
          row = []
          row << index + 1
          row << student[:student].full_name
          student[:dockets].each do |docket|
            if @period.kt_2?
              kt_1 = docket[:grades][:kt_1].present? ? docket[:grades][:kt_1].to_s : 'нет оценки'
              row << kt_1 << docket[:grades][:kt_2].to_s
            else
              row << docket[:grades][:kt_1].to_s
            end
          end
          sheet.add_row row, style: normal_text
        end

        sheet.add_row []
        dockets.each do |docket|
          t = []
          t << "#{docket.abbr} - #{docket.discipline}"
          (group.dockets.count + 1).times {t << ''}
          sheet.add_row t
        end
        sheet.rows[(3 + group.students.count)..-1].each do |row|
          sheet.merge_cells row.cells[0..-1]
        end
        sheet.column_widths 5, nil, 15
        sheet.col_style 0, left_align_without_border
        sheet.col_style 0, @period.kt_2? ? wrap_text2 : wrap_text, :row_offset => 1
        sheet.col_style 0, wrap_text3, :row_offset => 2 if @period.kt_2?
        sheet.col_style 1, @period.kt_2? ? wrap_text2 : wrap_text, :row_offset => 1
        sheet.col_style 1, wrap_text3, :row_offset => 2 if @period.kt_2?
        sheet.col_style 0, normal_text, :row_offset => @period.kt_2? ? 3 : 2
        sheet.col_style 1, left_align_text, :row_offset => @period.kt_2? ? 3 : 2
        sheet.col_style 0, left_align_without_border, :row_offset => (3 + group.students.count)
        sheet.sheet_view.show_grid_lines = false
      end
    end
    package.serialize("#{get_directory(dir).first}#{Russian.translit(group.title)}.xlsx")
  end
end
