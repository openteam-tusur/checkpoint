require 'progress_bar'
require 'docket_subdivision'

include DocketSubdivision

desc 'Set subdivisions for dockets'
task :set_subdivisions => :environment do
  dockets = Docket.all
  pb = ProgressBar.new(dockets.count)
  dockets.each do |docket|
    docket.update_attributes(:providing_subdivision_id => docket.subdivision_id,
                             :releasing_subdivision_id => get_subdivision(docket.group, :sub_faculty).id,
                             :faculty_id => get_subdivision(docket.group, :faculty).id)
    pb.increment!
  end
end

