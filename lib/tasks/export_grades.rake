require 'consolidated_export'
require 'csv_export'
require 'compress'
require 'progress_bar'

def to_consolidated_pdf(period, compress)
  puts 'Экспорт сводных ведомостей'
  pb = ProgressBar.new(period.groups.count)

  period.groups.each do |group|
    ConsolidatedExport.new(period, group).render_to_file
    pb.increment!
  end
  compress.to_zip('consolidated_pdf')
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
  task :consolidated_pdf => :environment do
    export('consolidated_pdf')
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
