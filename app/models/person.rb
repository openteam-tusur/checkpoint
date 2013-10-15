class Person < ActiveRecord::Base
  belongs_to :group
  attr_accessible :name, :patronymic, :surname, :type
  alias_attribute :to_s, :full_name

  def full_name
    [].tap do |s|
      s << surname
      s << name
      s << patronymic
    end.compact.join(' ')
  end
end
