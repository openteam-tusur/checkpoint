require 'axlsx'
require 'fileutils'
require 'progress_bar'

class LecturersStatisticExporter

  def initialize(hash, filename)
    @hash = hash
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

      end

      wb.add_worksheet do  |ws|

        lecturer_index = 1
        @hash.each do |lecturer, years|
          lecturer_and_years = []
          semesters_list = [nil, nil]
          kinds_list = [nil, nil]
          mark_kinds_list = [nil, nil]
          marks_list = [nil, nil]
          lecturer_and_years << lecturer
          lecturer_and_years << lecturer.dockets.where(kind: 'kt').first.try(:subdivision).try(:abbr)

          years_merges = []
          semesters_merges = []
          periods_merges = []
          years.each do |year, semesters|
            lecturer_and_years << year

            year_merges = 0
            semesters.each do |semester, kinds|
              semesters_list << semester
              semester_merges = 0
              kinds.each do |kind, marks|
                marks.delete_if{ |k,v| ["Зачтено", "Не зачтено"].include? k} if ["kt_1", "kt_2"].include? kind
                kinds_list << kind
                kinds_list += (2..marks.size).map {|k| nil}

                periods_merges << marks.size
                semester_merges += marks.size
                year_merges += marks.size

                marks.keys.sort.each do |mark_kind|
                  mark_kinds_list << mark_kind
                  marks_list << marks[mark_kind]
                end
              end
              semesters_list += (2..semester_merges).map {|k| nil}
              semesters_merges << semester_merges
            end
            lecturer_and_years += (2..year_merges).map {|s| nil}
            years_merges << year_merges
          end
          ws.add_row lecturer_and_years
          ws.add_row semesters_list
          ws.add_row kinds_list
          ws.add_row mark_kinds_list
          ws.add_row marks_list

          pb.increment!

          #index = 2
          #years_merges.each do |year_merge|
            #ws.merge_cells ws.rows[-5].cells[(index..(index-1+year_merge))]
            #index += year_merge
          #end
          #index = 2
          #periods_merges.each do |merge|
            #ws.merge_cells ws.rows[-3].cells[(index..(index-1+merge))]
            #index += merge
          #end
          #index = 2
          #semesters_merges.each do |merge|
            #ws.merge_cells ws.rows[-4].cells[(index..(index-1+merge))]
            #index += merge
          #end


          ws.merge_cells "A#{lecturer_index}:A#{lecturer_index+4}"
          ws.merge_cells "B#{lecturer_index}:B#{lecturer_index+4}"
          lecturer_index += 5
        end

      end
    end
    @package.serialize @filename
  end
end
