require 'whenever/capistrano'
require 'openteam/capistrano/recipes'

set :shared_children, fetch(:shared_children) + %w[public/files]
set :default_stage, :tusur
