if defined?(Capistrano::Configuration.instance)
  require 'a9n/capistrano/ver2x.rb'
else
  load File.expand_path('capistrano/tasks.cap', __dir__)
end
