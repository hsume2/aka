module Aka
  class Configuration
    FORMAT = '2'

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

    def configuration
      @configuration ||= begin
        aka = if File.exist?(aka_yml)
          YAML::load_file(aka_yml)
        else
          {}
        end
        aka[:shortcuts] ||= {}
        aka
      end
    end

    def shortcuts
      @shortcuts ||= Shortcuts.new(configuration[:shortcuts])
    end

    def version
      configuration[:version]
    end

    def save
      aka = {
        :version => version || FORMAT,
        :shortcuts => shortcuts.all
      }

      aka_link = {
        :version => version || FORMAT
      }
      aka_link[:links] = links.all if links.any?

      File.open(aka_yml, 'w+') do |f|
        f.write aka.to_yaml
      end

      File.open(aka_link_yml, 'w+') do |f|
        f.write aka_link.to_yaml
      end
    end

    def links
      @links ||= begin
        aka_link = if File.exist?(aka_link_yml)
          YAML::load_file(aka_link_yml)
        else
          {}
        end

        Links.new(aka_link[:links] || [])
      end
    end

    def upgrade
      if !version
        Upgrader::FromV0ToV1.run(aka_yml)
      elsif version == '1'
        Upgrader::FromV1ToV2.run(aka_yml, aka_link_yml)
      end
    end

    def aka_yml
      ENV['AKA'] || File.expand_path('~/.aka.yml')
    end

    def aka_link_yml
      ENV['AKA_LINK'] || File.expand_path('~/.aka.link.yml')
    end
  end
end
