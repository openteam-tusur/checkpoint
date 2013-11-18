module ApplicationHelper
  def summary_dockets_link(period, subdivision)
    if period.id == 1
      path = "/grades/#{subdivision.folder_name}"
    else
      path = "/grades/#{period.year}/#{period.season_type}/#{period.kind}/#{subdivision.folder_name}"
    end
    if File.directory?("public#{path}")
      link_to "Скачать ведомости", "#{path}/#{subdivision.abbr_translit}.zip"
    end
  end
end
