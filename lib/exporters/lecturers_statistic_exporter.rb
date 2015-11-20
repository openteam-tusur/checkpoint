require 'axlsx'
require 'fileutils'
require 'progress_bar'

class LecturersStatisticExporter

  def initialize(hash, periods_list, filename)
    @hash = hash
    @periods_list = periods_list
    @filename = filename
    @package = Axlsx::Package.new
  end

  def display_hash
    puts @hash
  end

  def export_to_xlsx
    pb = ProgressBar.new(@hash.size)
    @package.workbook do |wb|

      wb.styles do |s|
        blue_cell = s.add_style :bg_color => "B7DEE8", :fg_color => "00", :sz => 12, :alignment => { :horizontal=> :center  }
        title_cell = s.add_style :bg_color => "FFF", :fg_color => "00", :sz => 14, :alignment => { :horizontal => :center, :vertical => :center  },
          :border => {:style => :thin, :color => "00"}


      # Формируем шапку
      header = ['Преподаватель', 'Кафедра', 'Сумма', nil, nil, nil, nil, nil, nil, nil, nil, 'Абс.успеваемость', 'Качественная успеваемость', nil, nil]
      header_length = header.length
      header_semesters = []
      header_semesters += (1..15).map {|k| nil}
      header_kinds = []
      header_kinds += (1..15).map {|k| nil}
      grades_list = ['-', '2', '3', '4', '5', 'Зачтено', 'Не зачтено', 'н/а']
      header_data = [nil, nil, 'Всего', '-', '2', '3', '4', '5', 'Зачтено', 'Не зачтено', 'н/а', 'Абс.усп.', 'Качество', 'Тройки', 'Провалы']

      @periods_list.each do |year, semesters|
        semesters.each do |semester, kinds|
          kinds.each do |kind|
            if kind.last == "Экзаменационная сессия"
              header << year
              header += (1..7).map {|k| nil}
              header_semesters << semester
              header_semesters += (1..7).map {|k| nil}
              header_kinds << kind.last
              header_kinds += (1..7).map {|k| nil}
              header_data += grades_list
            end
          end
        end

      end
      # end шапка

      wb.add_worksheet do |ws|
        ws.add_row header, :style => Array.new(header_length, title_cell)
        ws.add_row header_semesters
        ws.add_row header_kinds
        ws.add_row header_data, :style => blue_cell

        ws.col_style 2, blue_cell, :row_offset => 3

        ws.merge_cells "A1:A3"
        ws.merge_cells "B1:B3"
        ws.merge_cells "L1:L3"
        ws.merge_cells "B1:B3"
        ws.merge_cells "M1:M3"
        ws.merge_cells "N1:N3"
        ws.merge_cells "O1:O3"
        ws.merge_cells "C1:K3"



      # Отрисовка данных по сотрудникам

        @hash.each do |lecturer, years|
        lecturer_data = []
        grades_summary = {}
        kinds_grades = []
          lecturer_data << lecturer
          lecturer_data << lecturer.dockets.where(kind: 'kt').first.try(:subdivision).try(:abbr)


          years.each do |year, semesters|
            semesters.each do |semester, kinds|
              kinds.each do |kind, marks|
                if kind == "Экзаменационная сессия"
                  kinds_grades << marks
                  grades_summary = marks.merge(grades_summary) {|key, val1, val2| val1+val2}
                end
              end
            end
          end

          sum = 0
          grades_summary.values.to_a.each do |m|
            sum += m
          end

          lecturer_data << sum

          grades_summary = Hash[grades_summary.sort]
          grades_summary.values.to_a.each do |marks_count|
            lecturer_data << marks_count
          end

          #Расчет Абсолютной успеваемости
          calc_grades = 0
          ['3', '4', '5', 'Зачтено'].each do |grade|
            calc_grades += grades_summary[grade]
          end

          abs_usp = (calc_grades.to_f / sum) * 100
          sum != 0 ? lecturer_data << "#{abs_usp.to_i}%" : lecturer_data << "-"
          # end

          #Расчет качества
          calc_grades =0
          ['4', '5', 'Зачтено'].each do |grade|
            calc_grades += grades_summary[grade]
          end

          quality = (calc_grades.to_f / sum) * 100
          sum != 0 ? lecturer_data << "#{quality.to_i}%" : lecturer_data << "-"
          # end

          #Расчет троек
          calc_grades =0
          ['3'].each do |grade|
            calc_grades += grades_summary[grade]
          end

          third = (calc_grades.to_f / sum) * 100
          sum != 0 ? lecturer_data << "#{third.to_i}%" : lecturer_data << "-"
          #end

          #Расчет провалов
          calc_grades =0
          ['-', '2', 'Не зачтено', 'н/а'].each do |grade|
            calc_grades += grades_summary[grade]
          end

          fails = (calc_grades.to_f / sum) * 100
          sum != 0 ? lecturer_data << "#{fails.to_i}%" : lecturer_data << "-"
          #end

          kinds_grades.each do |kind|
            kind = Hash[kind.sort]
            kind.values.each do |mark|
              lecturer_data << mark
            end

          end


          ws.add_row lecturer_data
        end
      end
    end
  end
    @package.serialize @filename
  end
end
