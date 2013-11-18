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
    pb2 = ProgressBar.new(period.dockets.count)

    period.groups.each do |group|
      xls_export.to_xls(group)
      pb.increment!
    end if period.not_session?

    period.dockets.each do |docket|
      Pdf.new(docket).render_to_file
      pb2.increment!
    end unless period.not_session?

    compress.to_zip
  end
end
