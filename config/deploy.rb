require 'openteam/capistrano/recipes'
require 'whenever/capistrano'

set :shared_children, fetch(:shared_children) + %w[public/files]
set :default_stage, :tusur
