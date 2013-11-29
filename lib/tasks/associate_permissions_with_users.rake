desc 'Associate permissions with existed users'
task :associate_permissions => :environment do
  Permission.where(:user_id => nil).each do |p|
    u = User.find_by_email(p.email)
    next if u.nil?
    p.user = u
    p.save
  end
end
