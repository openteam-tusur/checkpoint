module Export
  def previous_period
    return nil unless @period.kt_2?
    @previous_period ||= Period.by_kind('kt_1', @period.season_type, @period.year).first
  end

  def previous_group
    @pervious_group ||= previous_period.groups.find_by_title(@group.title) if previous_period
  end

  def subdivision
    @subdivision ||= if @period.not_session?
                       @group.chair
                     else
                       @group.faculty
                     end
  end
end
