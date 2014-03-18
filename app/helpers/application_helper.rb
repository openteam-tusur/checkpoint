module ApplicationHelper
  def summary_dockets_link(period, subdivision, file_format)
    if period.id == 1
      path = "/grades/#{subdivision.folder_name}"
    else
      path = "/grades/#{period.year}/#{period.season_type}/#{period.kind}_#{period.id}/#{subdivision.folder_name}"
    end
    file_name = "#{subdivision.abbr_translit}_#{file_format}"
    if File.exist?("public#{path}/#{file_name}.zip")
      content_tag(:li, link_to("Скачать #{I18n.t("docket.file_format.#{file_format}")}", "#{path}/#{file_name}.zip"))
    end
  end

  def summary_dockets_links(period)
    [].tap do |arr|
      arr << summary_dockets_link(period, @subdivision, 'pdf') unless period.not_session?
      arr << summary_dockets_link(period, @subdivision, 'consolidated_pdf')
      arr << summary_dockets_link(period, @subdivision, 'consolidated_xls')
      arr << summary_dockets_link(period, @subdivision, 'csv') if (period.not_session? && period.editable?)
    end
  end
end
