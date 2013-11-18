require 'xls_export'
require 'compress'
require 'progress_bar'

desc 'Export grades'
task :export_grades => :environment do
  periods = Period.all
  periods.each do |period|
    next unless period.actual?
    puts "Экспорт #{period.title}"
    xls_export = XlsExport.new(period)
    compress = Compress.new(period)
    pb = ProgressBar.new(period.groups.count)

    period.groups.each do |group|
      xls_export.to_xls(group) if period.kt_1? || period.kt_2?
      pb.increment!
    end
    compress.to_zip
  end
end
