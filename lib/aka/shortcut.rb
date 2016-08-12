module Aka
  class Shortcut
    def self.parse(options)
      self.new.tap do |row|
        row.shortcut = options['shortcut']
        row.command = options['command']
        row.tag = options['tag'] if options['tag']
        row.description = options['description'] if options['description']
        row.function = options['function'] if options['function']
      end
    end

    def self.generate_output(row)
      string = if row.function
        <<-EOS.gsub(/^        /, '')
        function #{row.shortcut} {
          #{row.command}
        }
        EOS
      else
        %{alias #{row.shortcut}="#{row.command.gsub(%{"}, %{\\"})}"}
      end

      string
    end

    attr_accessor :shortcut
    attr_accessor :command
    attr_accessor :tag
    attr_accessor :description
    attr_accessor :function

    def to_hash
      {
        :shortcut => self.shortcut,
        :command => self.command,
        :tag => self.tag,
        :description => self.description,
        :function => self.function
      }
    end
  end
end
