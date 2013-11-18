class Compress
  def initialize(period)
    @period = period
  end

  def to_zip
    directories = Dir.glob("#{@period.docket_path}/*").select {|f| File.directory? f}
    pb = ProgressBar.new(directories.count)
    directories.each do |dir|
      sub_abbr = Subdivision.find_by_folder_name(dir.gsub(/#{@period.docket_path}\//,'')).abbr_translit
      puts "Архивирование #{sub_abbr}"
      file_paths = Dir.glob("#{dir}/*.xlsx")
      zip_file = "#{dir}/#{sub_abbr}.zip"

      Zip::File.open(zip_file, Zip::File::CREATE) do |zipfile|
        file_paths.each do |file_path|
          file_name = file_path.split('/').last
          if zipfile.find_entry(file_name)
            zipfile.replace(file_name, file_path)
          else
            zipfile.add(file_name, file_path)
          end
        end
      end
      File.chmod(0644, zip_file)
      pb.increment!
    end
  end
end
