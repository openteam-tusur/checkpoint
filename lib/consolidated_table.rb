class ConsolidatedTable
  include DocketsGrades

  def initialize(group)
    @group = group
  end

  def previous_group
    nil
  end
end
