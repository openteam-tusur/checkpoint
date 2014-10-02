# Be sure to restart your server when you modify this file.

Checkpoint::Application.config.session_store :redis_session_store,
  :serializer => :json,
  :redis => Settings['session_store'].to_hash,
  :domain => Settings['app.domain']
