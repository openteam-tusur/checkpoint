class GroupPeriods
  include Rails.application.routes.url_helpers

  def initialize(group, period, subdivision)
    @group = group
    @period = period
    @subdivision = subdivision
  end

  def current
    @period
  end

  def next
    available_periods[index_of(current) + 1]
  end

  def prev
    available_periods[index_of(current) - 1] unless index_of(current) == 0
  end

  def titles_with_urls
    available_periods.inject([]) do |array, period|
      array << [period.to_s, subdivision_period_group_url(@subdivision, period, @group.title, :host => Settings['app.host'], :protocol => 'https')]
    end
  end

  private
  def available_periods
    @available_periods ||= Group.where(:title => @group.title).sort_by(&:kind_order).map(&:period)
  end

  def index_of(elem)
    available_periods.index(elem)
  end
end
