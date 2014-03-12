require "a9n/version"
require "a9n/struct"
require "a9n/core_ext/hash"
require "yaml"
require "erb"

module A9n
  class ConfigurationNotLoaded < StandardError; end
  class MissingConfigurationFile < StandardError; end
  class MissingConfigurationData < StandardError; end
  class MissingConfigurationVariables < StandardError; end
  class NoSuchConfigurationVariable < StandardError; end

  DEFAULT_FILE = 'configuration.yml'
  DEFAULT_SCOPE = :configuration

  class << self
    def env
      @env ||= local_app_env || get_env_var("RAILS_ENV") || get_env_var("RACK_ENV") || get_env_var("APP_ENV")
    end

    def local_app_env
      local_app.env if local_app && local_app.respond_to?(:env)
    end

    def local_app
      @local_app ||= get_rails
    end

    def local_app=(local_app)
      @local_app = local_app
    end

    def root
      @root ||= local_app.root
    end

    def root=(path)
      path = path.to_s
      @root = path.empty? ? nil : Pathname.new(path.to_s)
    end

    def scope(name)
      instance_variable_get(var_name_for(name)) || (name == DEFAULT_SCOPE && load)
    end

    def load(*files)
      files = [DEFAULT_FILE] if files.empty?
      files.each do |file|
        env_config     = load_env_config(file)
        default_config = load_default_config(file)

        whole_config   = default_config.merge(env_config)

        instance_variable_set(var_name_for(file), A9n::Struct.new(whole_config))
      end
    end

    def load_env_config(file)
      base     = load_yml("config/#{file}.example", env)
      local    = load_yml("config/#{file}", env)

      if base.nil? && local.nil?
        raise MissingConfigurationFile.new("Neither config/#{file}.example nor config/#{file} was found")
      end

      if !base.nil? && !local.nil?
        verify!(base, local)
      end

      local || base
    end

    def load_default_config(file = "configuration.yml")
      data   = load_yml("config/#{file}.example", "defaults", false)
      data ||= load_yml("config/#{file}", "defaults", false)
      data ||= {}
      return data
    end

    def load_yml(file, env, raise_when_not_found = true)
      path = File.join(self.root, file)
      return nil unless File.exists?(path)
      yml = YAML.load(ERB.new(File.read(path)).result)

      if yml[env].is_a?(Hash)
        return yml[env].deep_symbolize_keys
      elsif raise_when_not_found
        raise MissingConfigurationData.new("Configuration data for #{env} was not found in #{file}")
      else
        return nil
      end
    end

    # Fixes rspec issue
    def to_ary
      nil
    end

    def fetch(*args)
      scope(DEFAULT_SCOPE).fetch(*args)
    end

    def method_missing(name, *args)
      if scope(name).is_a?(A9n::Struct)
        scope(name)
      else
        scope(DEFAULT_SCOPE).send(name, *args)
      end
    end

    def get_rails
      defined?(Rails) ? Rails : nil
    end

    def get_env_var(name)
      ENV[name]
    end

    private

    def verify!(base, local)
      missing_keys = base.keys - local.keys
      if missing_keys.any?
        raise MissingConfigurationVariables.new("Following variables are missing in your configuration file: #{missing_keys.join(",")}")
      end
    end

    def var_name_for(file)
      :"@#{file.to_s.split('.').first}"
    end
  end
end
