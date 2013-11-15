require 'xls_export'
require 'progress_bar'

desc 'Export grades'
task :export_grades => :environment do
  periods = Period.all
  periods.each do |period|
    next unless period.actual?
    puts "Экспорт #{period.title}"
    export = XlsExport.new(period)
    pb = ProgressBar.new(period.groups.count)

    period.groups.each do |group|
      export.to_xls(group) if period.kt_1? || period.kt_2?
      pb.increment!
    end
    export.to_zip
  end
end
