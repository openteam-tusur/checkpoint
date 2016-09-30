require 'exporters/json_export'
require 'progress_bar'

desc 'Generate closed_sessions to JSONs'
task :generate_json => :environment do
  periods = Period.closed_sessions.joins(:students)
  bar = ProgressBar.new(periods.count)
  periods.each do |period|
    JsonExport.new(period).to_file if Time.zone.today > period.ends_at && Time.zone.today-14.days <= period.ends_at
    bar.increment!
  end
end

desc 'Generate closed_kts to JSONs'
task :generate_kt_jsons => :environment do
  periods = Period.closed_kts.joins(:students)
  bar = ProgressBar.new(periods.count)
  periods.each do |period|
    JsonExport.new(period).to_file
    bar.increment!
  end
end
