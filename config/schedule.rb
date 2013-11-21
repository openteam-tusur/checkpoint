 every 1.day, :at => '1:00 am' do
   rake :import_attendances, :output => { :error => 'log/error-import_attendances.log', :standard => 'log/import_attendances.log'}
 end

 every 1.day, :at => '03:00 am' do
   rake 'export:xlsx', :output => { :error => 'log/error-export_xlsx.log', :standard => 'log/export_xlsx.log'}
 end
 every 1.day, :at => '04:00 am' do
   rake 'export:csv', :output => { :error => 'log/error-export_csv.log', :standard => 'log/export_csv.log'}
 end
 every 1.day, :at => '05:00 am' do
   rake 'export:pdf', :output => { :error => 'log/error-export_pdf.log', :standard => 'log/export_pdf.log'}
 end
