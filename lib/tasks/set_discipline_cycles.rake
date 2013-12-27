require 'progress_bar'

desc 'Set discipline cycles'
task :set_discipline_cycles => :environment do
  periods = Period.where(:kind => :exam_session)
  periods.each do |period|
    puts "Setting discipline cycles for period #{period.id}"
    pb = ProgressBar.new(period.dockets.count)
    period.dockets.each do |docket|
      if docket.discipline.match('ГПО')
        docket.update_attributes(:discipline_cycle => :gpo)
      elsif docket.discipline.match('\*\*')
        docket.update_attributes(:discipline_cycle => :alternative)
      end
      pb.increment!
    end
  end
end
