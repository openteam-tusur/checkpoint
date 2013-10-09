Airbrake.configure do |config|
  config.api_key = Settings['errors.key']
  config.host    = Settings['errors.host']
  config.port    = 80
end if Rails.env.production?
