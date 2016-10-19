class Person < ActiveRecord::Base
  belongs_to :group
  attr_accessible :name, :patronymic, :surname, :type
  alias_attribute :to_s, :full_name
  alias_attribute :abbr, :full_name

  def full_name
    [].tap do |s|
      s << surname
      s << name
      s << patronymic
    end.compact.join(' ')
  end

  def abbreviated_name
    [].tap do |s|
      s << surname
      s << name
      s << patronymic.split(//).first.concat('.') if patronymic.present?
    end.compact.join(' ')
  end

  def short_name
    [].tap do |s|
      s << surname
      s << name.to_s.split(//).first
      s << patronymic.to_s.split(//).first
    end.compact.join(' ')
  end
end
