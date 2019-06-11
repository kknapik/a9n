module A9n
  class Loader
    attr_reader :scope, :env, :local_file, :example_file, :struct

    COMMON_SCOPE = 'defaults'.freeze

    def initialize(file_path, scope, env)
      @scope = scope
      @env = ::A9n::StringInquirer.new(env.to_s)
      @local_file = file_path
      @example_file = "#{file_path}.example"
    end

    def get
      struct || load
    end

    def load
      local_config    = self.class.load_yml(local_file, scope, env)
      example_config  = self.class.load_yml(example_file, scope, env)

      ensure_data_presence!(local_config, example_config)
      ensure_keys_presence!(local_config, example_config)

      @struct = A9n::Struct.new(local_config || example_config)
    end

    class << self
      def load_yml(file_path, scope, env)
        return nil unless File.exist?(file_path)

        yml = YAML.load(ERB.new(File.read(file_path)).result)

        common_scope = prepare_yml_scope(yml, scope, COMMON_SCOPE)
        env_scope    = prepare_yml_scope(yml, scope, env)

        A9n::Hash.merge(common_scope, env_scope)
      end

      def prepare_yml_scope(yml, scope, env)
        return nil unless yml[env].is_a?(::Hash)

        A9n::Hash.deep_prepare(yml[env], scope)
      end
    end

    private

    def ensure_data_presence!(local, example)
      return unless local.nil?
      return unless example.nil?

      raise A9n::MissingConfigurationDataError, "Configuration data for *#{env}* env was not found in neither *#{example}* nor *#{local}*"
    end

    def ensure_keys_presence!(local, example)
      return if local.nil?
      return if example.nil?

      missing_keys = example.keys - local.keys

      return if missing_keys.empty?

      raise A9n::MissingConfigurationVariablesError, "Following variables are missing in #{local_file} file: #{missing_keys.join(',')}"
    end
  end
end
