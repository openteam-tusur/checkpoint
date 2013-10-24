 set :output, 'log/import.log'

 every 1.day, :at => '5:00 am' do
   rake :import_attendances
 end

 every 3.hours do
   rake :export_grades
 end
