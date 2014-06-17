require 'exporters/consolidated_export'
require 'exporters/csv_export'
require 'compress'
require 'progress_bar'

def to_consolidated_pdf(period, compress)
  puts 'Экспорт сводных ведомостей'
  pb = ProgressBar.new(period.groups.count)

  period.groups.each do |group|
    ConsolidatedExport.new(period, group).render_to_file
    pb.increment!
  end
  compress.to_zip
end

def to_consolidated_xls(period, compress)
  puts 'Экспорт сводных ведомостей'
  pb = ProgressBar.new(period.groups.count)

  period.groups.each do |group|
    XlsExport.new(period, group).to_xls
    pb.increment!
  end
  compress.to_zip
end

def to_csv(period, compress)
  puts 'Экспорт CSV'
  pb = ProgressBar.new(period.dockets.count)

  period.dockets.each do |docket|
    CsvExport.new(docket).to_csv_file
    pb.increment!
  end
  compress.to_zip
end

def to_pdf(period, compress)
  puts 'Экспорт PDF'
  pb = ProgressBar.new(period.dockets.count)

  period.dockets.each do |docket|
    Pdf.new(docket).render_to_file
    pb.increment!
  end
  compress.to_zip
end

def export(format)
  periods = Period.all
  periods.each do |period|
    next unless (period.actual? && period.groups.any?)

    case format
    when /consolidated\w+/
      next if period.dockets.filled.empty?
    when 'pdf'
      next if period.not_session?
    when 'csv'
      next unless period.not_session?
    end

    puts "Экспорт #{period.title}, Period ID: #{period.id}"
    compress = Compress.new(period, format)
    send("to_#{format}", period, compress)
  end
end

namespace :export do
  desc 'export pdf consolidated dockets'
  task :consolidated_pdf => :environment do
    export('consolidated_pdf')
    message = I18n.localize(Time.now, :format => :short) + "Экспорт сводных ведомостей в PDF выполнен"
    Airbrake.notify(:error_class => "rake export:consolidated_pdf", :error_message => message)
  end

  desc 'export xlsx consolidated dockets'
  task :consolidated_xls => :environment do
    export('consolidated_xls')
    message = I18n.localize(Time.now, :format => :short) + "Экспорт сводных ведомостей в XLS выполнен"
    Airbrake.notify(:error_class => "rake export:consolidated_xls", :error_message => message)
  end

  desc 'export csv dockets'
  task :csv => :environment do
    export('csv')
    message = I18n.localize(Time.now, :format => :short) + "Экспорт CSV ведомостей выполнен"
    Airbrake.notify(:error_class => "rake export:csv", :error_message => message)
  end

  desc 'export pdf dockets'
  task :pdf => :environment do
    export('pdf')
    message = I18n.localize(Time.now, :format => :short) + "Экспорт PDF ведомостей выполнен"
    Airbrake.notify(:error_class => "rake export:pdf", :error_message => message)
  end
end
