class GroupPeriods
  include Rails.application.routes.url_helpers

  def initialize(group, period)
    @group = group
    @period = period
  end

  def current
    @period
  end

  def subdivision
    @subdivision ||= @period.not_session? ? @group.chair : @group.faculty
  end

  def next
    available_periods[index_of(current) + 1]
  end

  def prev
    available_periods[index_of(current) - 1] unless index_of(current) == 0
  end

  def titles_with_urls
    available_periods.inject([]) do |array, period|
      array << [period.to_s, subdivision_period_group_url(subdivision, period, @group.title, :host => Settings['app.host'])]
    end
  end

  private
  def available_periods
    @available_periods ||= Group.where(:title => @group.title).by_period_asc.map(&:period)
  end

  def index_of(elem)
    available_periods.index(elem)
  end
end
