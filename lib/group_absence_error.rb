class GroupAbsenceError < StandardError
  attr_accessor :group

  def initialize(group)
    @group = group
  end

  def message
    "#{self.class.name}: Не могу найти группу #{group}"
  end
end
