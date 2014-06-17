require 'exporters/json_export'

desc 'Generate JSON'
task :generate_json => :environment do
  periods = Period.closed_sessions
  periods.each do |period|
    JsonExport.new(period).to_file if (period.ends_at + 1) == Time.zone.today
  end
end
