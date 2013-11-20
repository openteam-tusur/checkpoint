module ApplicationHelper
  def summary_dockets_link(period, subdivision, file_format)
    if period.id == 1
      path = "/grades/#{subdivision.folder_name}"
    else
      path = "/grades/#{period.year}/#{period.season_type}/#{period.kind}/#{subdivision.folder_name}"
    end
    if File.directory?("public#{path}")
      link_to "Скачать #{I18n.t("docket.file_format.#{file_format}")}", "#{path}/#{subdivision.abbr_translit}_#{file_format}.zip"
    end
  end
end
