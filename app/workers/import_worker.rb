class ImportWorker
  include Sidekiq::Worker

  def perform(period_id, group_pattern)
    period = Period.find(period_id)

    Import.new(period, group_pattern).import
  end
end
