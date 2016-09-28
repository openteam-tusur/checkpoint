require 'exporters/json_export'

desc 'Generate JSON'
task :generate_json => :environment do
  periods = Period.closed_sessions
  periods.each do |period|
    JsonExport.new(period).to_file if Time.zone.today > period.ends_at && Time.zone.today-14.days <= period.ends_at
  end
end

task :generate_kt_jsons => :environment do
  periods = Period.closed_kts
  periods.each do |period|
    JsonExport.new(period).to_file
  end
end
