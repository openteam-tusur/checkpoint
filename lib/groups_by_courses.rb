class GroupsByCourses
  def initialize(subdivision)
    @subdivision = subdivision
  end

  def groups
    @groups ||= @subdivision.groups
  end

  def available_courses
    groups.map(&:course).uniq.sort
  end

  def available_courses_for_group(group)
    groups.where(:title => group).map(&:course).sort.uniq
  end

  def group_hash
    group_hash = {}
    groups.ordered.uniq_by(&:title).each do |group|
      group_hash.merge!({ group => available_courses_for_group(group.title)})
    end

    group_hash
  end

  def group
    course_hash = {}

    available_courses.each do |course|
      group_arr = []
      group_hash.each do |group, courses|
        group_arr << group if courses.last == course
      end
      course_hash.merge!({ course => group_arr})
    end

    course_hash
  end
end
