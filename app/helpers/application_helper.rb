module ApplicationHelper
  def summary_dockets_link(period, subdivision, file_format)
    if period.id == 1
      path = "/grades/#{subdivision.folder_name}"
    else
      path = "/grades/#{period.year}/#{period.season_type}/#{period.kind}_#{period.id}/#{subdivision.folder_name}"
    end
    file_name = "#{subdivision.abbr_translit}_#{file_format}"
    if File.exist?("public#{path}/#{file_name}.zip")
      link_to "Скачать #{I18n.t("docket.file_format.#{file_format}")}", "#{path}/#{file_name}.zip"
    end
  end
end
