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

      def self.generate_output(row)
        string = if row.function
          <<-EOS.gsub(/^          /, '')
          function #{row.shortcut} {
            #{row.command}
          }
          EOS
        else
          %{alias #{row.shortcut}="#{row.command.gsub(%{"}, %{\\"})}"}
        end

        string
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

    def shortcuts
      @shortcuts ||= Shortcuts.new(self, @configuration[:shortcuts])
    end

    def version
      @configuration[:version]
    end

    def save
      current = {
        :version => version || FORMAT,
        :shortcuts => shortcuts.all
      }

      current[:configs] = @configuration[:configs] if @configuration[:configs]

      File.open(aka_yml, 'w+') do |f|
        f.write current.to_yaml
      end
    end

    def add_configuration(config)
      @configuration[:configs] ||= []
      @configuration[:configs] << config
    end

    def upgrade
      if !version
        Upgrader::FromV0.run(aka_yml)

        puts "Upgraded #{aka_yml}."
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
