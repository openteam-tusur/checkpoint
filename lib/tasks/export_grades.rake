require 'xls_export'
require 'csv_export'
require 'compress'
require 'progress_bar'

desc 'Export grades'
task :export_grades => :environment do
  periods = Period.all
  periods.each do |period|
    next unless (period.actual? && period.groups.any?)

    puts "Экспорт #{period.title}, Period ID: #{period.id}"
    xls_export = XlsExport.new(period)
    compress = Compress.new(period)
    gb = ProgressBar.new(period.groups.count)
    db = ProgressBar.new(period.dockets.count)

    puts 'Экспорт XLS'
    period.groups.each do |group|
      xls_export.to_xls(group)
      gb.increment!
    end
    compress.to_zip('xlsx')

    if period.not_session?
      puts 'Экспорт CSV'
      period.dockets.each do |docket|
        CsvExport.new(docket).to_csv_file
        db.increment!
      end
      compress.to_zip('csv')
    end

    unless period.not_session?
      puts 'Экспорт PDF'
      db = ProgressBar.new(period.dockets.count)
      period.dockets.each do |docket|
        Pdf.new(docket).render_to_file
        db.increment!
      end
      compress.to_zip('pdf')
    end
  end
end
