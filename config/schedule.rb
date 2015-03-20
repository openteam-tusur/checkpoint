 every 1.day, :at => '1:00 am' do
   rake :import_attendances, :output => { :error => 'log/error-import_attendances.log', :standard => 'log/import_attendances.log'}
 end

 every 1.day, :at => '05:00 am' do
   rake 'export:consolidated_pdf', :output => { :error => 'log/error-export_consolidated_pdf.log', :standard => 'log/export_consolidated_pdf.log'}
 end

 every 1.day, :at => '06:00 am' do
   rake 'export:consolidated_xls', :output => { :error => 'log/error-export_consolidated_xls.log', :standard => 'log/export_consolidated_xls.log'}
 end

 every 1.day, :at => '07:00 am' do
   rake 'export:csv', :output => { :error => 'log/error-export_csv.log', :standard => 'log/export_csv.log'}
 end

 every 1.day, :at => '08:00 am' do
   rake 'export:pdf', :output => { :error => 'log/error-export_pdf.log', :standard => 'log/export_pdf.log'}
 end

 every 1.day, :at => '02:00 am' do
   rake :export_json, :output => { :error => 'log/error-export_json.log', :standart => 'log/export_json.log' }
 end

 every 1.day, :at => '11:00 pm' do
   rake  :sync_students, :output => { :error => 'log/error-import_students.log', :standart => 'log/import_students' }
 end
