 set :output, 'log/import.log'

 every 1.day, :at => '2:00 am' do
   rake :import
 end
