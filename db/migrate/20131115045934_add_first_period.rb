class AddFirstPeriod < ActiveRecord::Migration
  def up
    Period.skip_callback(:create, :after, :create_dockets)
    period = Period.create(
      :starts_at => Time.zone.parse('2013-10-14'),
      :ends_at => Time.zone.parse('2013-10-25'),
      :kind => :kt_1,
      :season_type => :autumn
    )
    Group.all.map {|g| g.update_attribute :period_id, period.id }
    Docket.all.map {|d| d.update_attribute :period_id, period.id }
  end
end
