class Compress
  def initialize(period, format)
    @period = period
    @format = format
  end

  def directories
    @directories ||= Dir.glob("#{@period.docket_path}/*").select {|f| File.directory? f}
  end

  def to_zip
    pb = ProgressBar.new(directories.count)

    directories.each do |dir|
      next if file_paths(dir).empty?

      abbr = sub_abbr(dir)
      puts "Архивирование #{abbr}"
      zip_file = zip_file_name(dir, abbr)

      Zip::File.open(zip_file, Zip::File::CREATE) do |zipfile|
        file_paths(dir).each do |file_path|
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

  private

  def sub_abbr(dir)
    Subdivision.find_by_folder_name(folder_name(dir)).abbr_translit
  end

  def zip_file_name(dir, abbr)
    "#{dir}/#{abbr}_#{@format}.zip"
  end

  def folder_name(dir)
    dir.gsub(/#{@period.docket_path}\//,'')
  end

  def file_paths(dir)
    case @format
    when 'consolidated_pdf'
      Dir.glob("#{dir}/consolidated/*.pdf")
    when 'consolidated_xls'
      Dir.glob("#{dir}/consolidated/*.xlsx")
    else
      Dir.glob("#{dir}/*.#{@format}")
    end
  end
end
