require 'open-uri'
require 'contingent_students'
require 'subdivision_abbrs'

class DocketSubdivision
  include SubdivisionAbbrs

  def initialize(group, type = '', abbr = '')
    @group = group
    @type = type
    @abbr = abbr
  end

  def group_attributes
    student_hash = ContingentStudents.new(@group).get_students.first
    faculty = student_hash['education']['params']['faculty']
    sub_faculty = student_hash['education']['params']['sub_faculty']

    {'faculty' => faculty, 'sub_faculty' => sub_faculty}
  end

  def get_subdivision
    if @abbr.present?
      get_subdivision_by_abbr
    else
      get_subdivision_by_type
    end
  end

  def get_subdivision_by_abbr
    sub = Subdivision.find_by_title(subdivision_titles[sub_abbr(@abbr)]) || Subdivision.find_by_abbr(sub_abbr(@abbr))
    unless sub
      sub = Subdivision.create(:abbr => sub_abbr(@abbr), :title => subdivision_titles[sub_abbr(@abbr)])
    end

    sub
  end

  def get_subdivision_by_type
    attributes = group_attributes
    sub = Subdivision.find_by_title(attributes[@type]["#{@type}_name"]) || Subdivision.find_by_abbr(sub_abbr(attributes[@type]['short_name']))
    unless sub
      sub = Subdivision.create(:abbr => sub_abbr(attributes[@type]['short_name']), :title => subdivision_titles[sub_abbr(attributes[@type]['short_name'])])
    end

    sub
  end
end
