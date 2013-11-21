require 'xls_export'
require 'csv_export'
require 'compress'
require 'progress_bar'

def to_xlsx(period, compress)
  xls_export = XlsExport.new(period)
  puts 'Экспорт XLS'
  pb = ProgressBar.new(period.dockets.count)

  period.groups.each do |group|
    xls_export.to_xls(group)
    pb.increment!
  end
  compress.to_zip('xlsx')
end

def to_csv(period, compress)
  if period.not_session?
    puts 'Экспорт CSV'
    pb = ProgressBar.new(period.dockets.count)

    period.dockets.each do |docket|
      CsvExport.new(docket).to_csv_file
      pb.increment!
    end
    compress.to_zip('csv')
  end
end

def to_pdf(period, compress)
  unless period.not_session?
    puts 'Экспорт PDF'
    pb = ProgressBar.new(period.dockets.count)

    period.dockets.each do |docket|
      Pdf.new(docket).render_to_file
      pb.increment!
    end
    compress.to_zip('pdf')
  end
end

def export(format)
  periods = Period.all
  periods.each do |period|
    next unless (period.actual? && period.groups.any?)
    puts "Экспорт #{period.title}, Period ID: #{period.id}"
    compress = Compress.new(period)
    send("to_#{format}", period, compress)
  end
end

namespace :export do
  desc 'export xlsx dockets'
  task :xlsx => :environment do
    export('xlsx')
  end

  desc 'export csv dockets'
  task :csv => :environment do
    export('csv')
  end

  desc 'export pdf dockets'
  task :pdf => :environment do
    export('pdf')
  end
end
