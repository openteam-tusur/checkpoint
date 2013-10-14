require 'openteam/capistrano/recipes'

set :shared_children, fetch(:shared_children) + %w[files]
set :default_stage, :tusur
