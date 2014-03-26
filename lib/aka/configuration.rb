module Aka
  class Configuration
    FORMAT = '1'

    attr_reader :configuration

    module Shortcut
      def self.parse(options)
        OpenStruct.new.tap do |row|
          row.shortcut = options['shortcut']
          row.command = options['command']
          row.tag = options['tag'] if options['tag']
          row.description = options['description'] if options['description']
          row.function = options['function'] if options['function']
        end
      end
    end

    module Config
      def self.parse(options)
        OpenStruct.new.tap do |row|
          row.tag = options['tag'] if options['tag']
          row.output = options['output'] if options['output']
        end
      end
    end

    def initialize
      @configuration ||= begin
        if File.exist?(aka_yml)
          YAML::load_file(aka_yml)
        else
          {}
        end
      end
      @configuration[:shortcuts] ||= {}
    end

    class Shortcuts
      def initialize(configuration, shortcuts)

      end
    end

    def _shortcuts
      @_shortcuts ||= Shortcuts.new(self, @configuration[:shortcuts])
    end

    def shortcuts
      @configuration[:shortcuts]
    end

    def version
      @configuration[:version]
    end

    def save
      current = {
        :version => version || FORMAT,
        :shortcuts => shortcuts
      }

      current[:configs] = @configuration[:configs] if @configuration[:configs]

      File.open(aka_yml, 'w+') do |f|
        f.write current.to_yaml
      end
    end

    def append_shortcut(shortcut)
      shortcuts[count + 1] = shortcut
    end

    def replace_shortcut(index, shortcut)
      shortcuts[index] = shortcut
    end

    def delete_shortcut(index)
      shortcuts.delete(index)
    end

    def add_configuration(config)
      @configuration[:configs] ||= []
      @configuration[:configs] << config
    end

    def upgrade
      if !version
        Upgrader::FromV0.run(aka_yml)
      end
    end

    def aka_yml
      ENV['AKA'] || File.expand_path('~/.aka.yml')
    end

    def count
      result, _ = shortcuts.max { |(n, _)| n }
      result || 0
    end
  end
end
