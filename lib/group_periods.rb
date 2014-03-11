class GroupPeriods
  def initialize(group, period)
    @group = group
    @period = period
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

private
  def available_periods
    @available_periods ||= Group.where(:title => @group.title).by_period_asc.map(&:period)
  end

  def index_of(elem)
    available_periods.index(elem)
  end
end
