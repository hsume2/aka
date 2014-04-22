module Aka
  class Configuration
    FORMAT = '2'

    attr_reader :configuration, :links

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

    module Link
      def self.parse(options)
        unless options['tag'] && options['output']
          abort("Invalid link.")
        end

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

      @links ||= begin
        links = YAML::load_file(aka_link) if File.exist?(aka_link)
        Links.new(links || [])
      end
    end

    def shortcuts
      @shortcuts ||= Shortcuts.new(@configuration[:shortcuts])
    end

    def version
      @configuration[:version]
    end

    def save
      current = {
        :version => version || FORMAT,
        :shortcuts => shortcuts.all
      }

      File.open(aka_yml, 'w+') do |f|
        f.write current.to_yaml
      end

      File.open(aka_link, 'w+') do |f|
        f.write links.all.to_yaml
      end if links.any?
    end

    def upgrade
      if !version
        Upgrader::FromV0To1.run(aka_yml)
      elsif version == '1'
        Upgrader::FromV1To2.run(aka_yml, aka_link)
      end
    end

    def aka_yml
      ENV['AKA'] || File.expand_path('~/.aka.yml')
    end

    def aka_link
      ENV['AKA_LINK'] || File.expand_path('~/.aka.link')
    end
  end
end
