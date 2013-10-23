require 'open-uri'
require 'axlsx'
require 'fileutils'
require 'progress_bar'

FACULTY_ABBR = {
  'ЭМиС' => 'ЭМИС',
  'ЭКОНОМ' => 'Экономики'
}

def get_students(group_number)
  JSON.parse(open("#{Settings['students.url']}/api/v1/students?group=#{URI.encode(group_number)}").read)
end

def group_attributes(group_number)
  student_hash = get_students(group_number).first
  faculty = student_hash['education']['params']['faculty']['short_name']
  sub_faculty = student_hash['education']['params']['sub_faculty']['short_name']
  course = student_hash['education']['params']['course']

  {:faculty => faculty, :sub_faculty => (FACULTY_ABBR[sub_faculty] || sub_faculty), :course => course}
end

def get_directory(dir)
  FileUtils.mkdir_p(dir)
end

def to_xls(group)
  attributes = group_attributes(group.contingent_number)
  folder_name = Subdivision.find_by_abbr(attributes[:sub_faculty]).folder_name
  dir = "public/grades/#{folder_name}/"
  package = Axlsx::Package.new
  wb = package.workbook
  wb.styles do |s|
    center_align = { :horizontal => :center,
                  :vertical => :center,
                  :wrap_text => true}
    left_align = { :horizontal => :left,
                   :vertical => :center,
                   :wrap_text => true}
    wrap_text = s.add_style :b => true,
      :sz => 14,
      :border => { :style => :medium, :color => "00" },
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
      info << "Успеваемость студентов по результатам первой контрольной точки\nпо состоянию на #{Time.now.strftime('%d.%m.%Y')}\nФакультет: #{attributes[:faculty]}\tКурс: #{attributes[:course]}\tГруппа: #{group}".mb_chars.upcase
      (group.dockets.count - 1).times { info << '' }
      sheet.add_row info, style: normal_without_border, height: 80
      sheet.merge_cells sheet.rows.first.cells[0..1]
      sheet.merge_cells sheet.rows.first.cells[2..-1]
      header = []
      header << '№' << 'ФИО Студента'
      header += group.students.first.grades.flat_map(&:docket).sort_by{|d| d.discipline }.map(&:abbr)
      sheet.add_row header, style: wrap_text
      group.students.each_with_index do |student, index|
        row = []
        row << index + 1
        row << student.full_name
        student.grades.sort_by{|g| g.docket.discipline }.each do |grade|
          row << grade.to_s
        end
        sheet.add_row row, style: normal_text
      end
      sheet.column_widths 5, nil, 15
      sheet.col_style 0, left_align_without_border
      sheet.col_style 0, wrap_text, :row_offset => 1
      sheet.col_style 0, normal_text, :row_offset => 2
      sheet.col_style 1, left_align_text, :row_offset => 2
      sheet.sheet_view.show_grid_lines = false
    end
  end
  package.serialize("#{get_directory(dir).first}#{Russian.translit(group.title)}.xlsx")
end

def to_zip
  directories = Dir.glob('public/grades/*').select {|f| File.directory? f}
  pb = ProgressBar.new(directories.count)
  directories.each do |dir|
    puts "Архивирование #{dir.gsub(/public\/grades\//,'')}"
    file_paths = Dir.glob("#{dir}/*.xlsx")
    sub_abbr = Russian.translit(Subdivision.find_by_folder_name(dir.gsub(/public\/grades\//,'')).abbr)
    zip_file = "#{dir}/#{sub_abbr}.zip"
    Zip::File.open(zip_file, Zip::File::CREATE) do |zipfile|
      file_paths.each do |file_path|
        file_name = file_path.split('/').last
        if zipfile.find_entry(file_name)
          zipfile.replace(file_name, file_path)
        else
          zipfile.add(file_name, file_path)
        end
      end
    end
    pb.increment!
  end
end

desc 'Export grades'
task :export_grades => :environment do
  groups = Group.all
  bar = ProgressBar.new(groups.count)
  groups.each do |group|
    to_xls(group)
    bar.increment!
  end
  to_zip
end
