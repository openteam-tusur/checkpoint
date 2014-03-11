require 'progress_bar'
require 'group_init'

desc 'Set faculty and chair for group'
task :update_groups => :environment do
  groups = Group.all
  pb = ProgressBar.new(groups.count)

  groups.each do |group|
    GroupInit.new(group.period, group.title, group.course).prepare_group
    pb.increment!
  end
end
