Sidekiq.configure_server do |config|
  config.redis = { :url => Settings['redis.url'], :namespace => 'checkpoint' }
end

Sidekiq.configure_client do |config|
  config.redis = { :url => Settings['redis.url'], :namespace => 'checkpoint' }
end
