require 'openteam/capistrano/deploy'

set :linked_dirs, fetch(:linked_dirs) + %w{ public/files public/grades }
