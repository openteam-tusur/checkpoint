require 'openteam/capistrano/deploy'

set :bundle_binstubs, -> { shared_path.join('bin') }

set :db_remote_clean, true

append :linked_dirs, 'public/files'
append :linked_dirs, 'public/grades'

set :slackistrano,
  channel: (Settings['slack.channel'] rescue ''),
  webhook: (Settings['slack.webhook'] rescue '')
