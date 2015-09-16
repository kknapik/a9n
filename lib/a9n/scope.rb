module A9n
  class Scope
    MAIN_NAME = :configuration

    attr_reader :name

    def initialize(name)
      @name = name.to_sym
    end

    def main?
      name == MAIN_NAME
    end

    def self.form_file_path(path)
      name = File.basename(path.to_s).split('.').first.to_sym
      self.new(name)
    end
  end
end
