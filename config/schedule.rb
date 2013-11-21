 every 1.day, :at => '5:00 am' do
   rake :import_attendances, :output => { :error => 'log/error-import_atendances.log', :standard => 'log/import_attendances.log'}
 end

 every 1.day, :at => '2:00 am' do
   rake :export_grades, :output => { :error => 'log/error-export_grades.log', :standard => 'log/export_grades.log'}
 end
