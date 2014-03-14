require 'open-uri'
require 'progress_bar'
require 'contingent_students'
require 'docket_subdivision'

class Import
  def initialize(period, group_pattern = '.*')
    @period = period
    @group_pattern = Regexp.new(group_pattern || ".*")
  end

  def import_lecturer(full_name)
    surname, name, patronymic = full_name.try(:split, /\s/)
    return nil unless surname.present?
    Lecturer.find_or_create_by_name_and_patronymic_and_surname(:name => name, :patronymic => patronymic, :surname => surname)
  end

  def get_attendance_for(student, discipline)
    JSON.parse(open(URI.encode("#{Settings['attendance.url']}api/attendance?group=#{student.group.title}&student=#{student.full_name}&discipline=#{discipline}")).read)
  end

  def create_attendances(student, docket)
    attendances = get_attendance_for(student, docket.discipline)
    return if attendances.has_key?('error')
    attendances.each do |discipline_kind, presences|
      student.attendances.find_or_initialize_by_docket_id_and_kind(:docket_id => docket.id, :kind => Attendance.kind_value(discipline_kind).to_s).tap do |attendance|
        attendance.fact = presences['was'].to_i + presences['valid_excuse'].to_i
        attendance.total = presences.map{|k,v| v}.reduce(:+)
        attendance.save!
      end
    end
  end

  def reimport_dockets
    file_url = Settings['subdivisions.url']
    response = open(file_url).read
    group_items = JSON.parse response

    group_items.each do |group_item|
      next if !@period.groups.map(&:title).include?(group_item['group']['number'])
      group = GroupInit.new(@period, group_item['group']['number'], nil).prepare_group
      docket_items = @period.exam_session? ? group_item['exam_dockets'] : group_item['checkpoint_dockets']
      create_dockets(docket_items, group)
    end
  end

  def import
    file_url = Settings['subdivisions.url']
    response = open(file_url).read
    group_items = JSON.parse response

    group_items.each do |group_item|
      next if !group_item['group']['number'].match(@group_pattern)
      group = GroupInit.new(@period, group_item['group']['number'], nil).prepare_group
      docket_items = @period.exam_session? ? group_item['exam_dockets'] : group_item['checkpoint_dockets']
      create_dockets(docket_items, group)
    end
  end

  def create_dockets(dockets_hash, group)
    dockets_hash.each do |discipline_hash|
      subdivision = DocketSubdivision.new(group, @period.not_session? ? 'sub_faculty' : 'faculty', nil).get_subdivision

      if @period.not_session?
        providing_subdivision = subdivision
      else
        providing_subdivision = DocketSubdivision.new(group, nil, discipline_hash['providing_subdivision_abbr']).get_subdivision
      end
      lecturer = import_lecturer(discipline_hash['lecturer'])

      docket = subdivision.dockets.find_or_initialize_by_discipline_and_group_id_and_lecturer_id_and_period_id_and_kind(
        :discipline => discipline_hash['discipline'],
        :group_id => group.id,
        :lecturer_id => lecturer ? lecturer.id : Lecturer.find_by_surname('Преподаватель не указан').id,
        :period_id => @period.id,
        :kind => discipline_hash['kind'] || :kt
      ).tap do |d|
        d.save(:validate => false)
      end
      docket.update_column(:providing_subdivision_id, providing_subdivision.id)
      unless docket.discipline_cycle
        docket.update_column(:discipline_cycle, discipline_hash['discipline_cycle'])
      end
      group.students.each do |student|
        create_attendances(student, docket)
      end
    end
  end
end
