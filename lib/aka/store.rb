require 'yaml'
require 'ostruct'
require 'tempfile'
require 'methadone'

module Aka
  class Store
    include Methadone::CLILogging

    def help(command, options)
      case command
      when nil       then command = "aka.7"
      else command = "aka-#{command}.1"
      end

      manpages = %w(
        aka-add.1
        aka-edit.1
        aka-generate.1
        aka-list.1
        aka-remove.1
        aka-show.1
        aka.7)

      exit unless manpages.include?(command)

      root = File.expand_path("../man", __FILE__)

      if !ENV['NO_MAN'] && Aka::App.which("man") && root !~ %r{^file:/.+!/META-INF/jruby.home/.+}
        Kernel.exec "man #{root}/#{command}"
      else
        puts File.read("#{root}/#{command}.txt")
        exit
      end
    end

    def add(options)
      found = find(options)

      if found.length > 0
        unless options[:force]
          abort %{Shortcut "#{options[:shortcut]}" exists. Pass --force to overwrite. Or provide a new --tag.}
        else
          found.each do |n, row|
            configuration.replace_shortcut(n, Configuration::Shortcut.parse(options))
          end
          configuration.save
          puts "Overwrote shortcut."
        end
      else
        configuration.append_shortcut(Configuration::Shortcut.parse(options))
        configuration.save
        puts "Created shortcut."
      end
    end

    def list(options)
      excluded = match_shortcuts_by_tag(options[:tag] || []) do |tag, rows|
        puts %{##{tag}}
        puts ''.ljust(tag.length + 1, '=')
        rows.each do |row|
          list_output(row)
        end
        puts
      end

      excluded_output(excluded)
    end

    def remove(options)
      found = find(options)

      if found.length > 0
        found.each do |n, row|
          configuration.delete_shortcut(n)
        end

        configuration.save

        puts "Removed shortcut."
      else
        abort %{No shortcut "#{options[:shortcut]}". Aborting.}
      end
    end

    def matches_tag?(row, tag)
      return true unless row.tag

      if tag =~ /^~(.+)/
        !row.tag.include?($1)
      else
        row.tag && row.tag.include?(tag)
      end
    end

    def generate(options)
      scripts = []
      functions = []

      excluded = match_shortcuts_by_tag(options[:tag] || []) do |tag, rows|
        rows.each do |row|
          unless row.function
            scripts << generate_output(row)
          else
            functions << generate_output(row)
          end
        end
      end

      if options[:output]
        File.open(options[:output], 'w+') do |f|
          scripts.each do |script|
            f.puts script
          end

          functions.each do |function|
            f.puts function
          end
        end

        puts "Generated #{options[:output]}."
      else
        scripts.each do |script|
          puts script
        end

        functions.each do |function|
          puts function
        end
      end

      excluded_output(excluded)
    end

    def config(options)
      configuration.add_configuration(Configuration::Config.parse(options))
      configuration.save

      puts "Saved configuration."
    end

    def sync
      # configuration.sync
    end

    def edit(options)
      result = nil

      found = find(options)

      index, row = found.first

      unless row
        abort "Shortcut not found."
      end

      if options[:input]
        result = File.read(options[:input])
      else
        file = Tempfile.new('shortcut')
        begin
          file.open
          if row.tag
            tags = %{ #{row.tag.join(', ')}}
          else
            tags = ''
          end
          file.write(<<-EOS.gsub(/^            /, '')
            Keyword: #{row.shortcut}
            Description:
            #{row.description}
            Function (y/n): #{row.function ? 'y' : 'n'}
            Tags:#{tags}
            Command:
            #{row.command}
          EOS
          )
          file.close
          editor = ENV['EDITOR'] || 'vim'
          system(%[#{editor} #{file.path}])
          debug("Editing exited with code: #{$?.exitstatus}.")
          if $?.exitstatus == 0
            file.open
            file.rewind
            result = file.read.strip
          end
        ensure
          file.unlink
        end
      end

      if result
        parse_row_txt(row, result)
        configuration.replace_shortcut(index, row)
        configuration.save
        puts "Saved shortcut."
      else
      end
    end

    def show(options)
      found = find(options)

      _, row = found.first

      if row
        puts show_output(row)
      else
        abort "Shortcut not found."
      end
    end

    def upgrade(options)
      configuration.upgrade

      puts "Upgraded #{configuration.aka_yml}."
    end

    private

    def configuration
      @configuration ||= Configuration.new
    end

    def shortcuts
      configuration.shortcuts
    end

    def find(options)
      if options[:tag]
        shortcuts.select do |_, row|
          next unless row.shortcut == options[:shortcut]

          options[:tag].find do |tag|
            row.tag && row.tag.include?(tag)
          end
        end
      else
        shortcuts.select do |_, row|
          row.shortcut == options[:shortcut]
        end
      end
    end

    def shortcuts_by_tag
      shortcuts.inject({ :default => [] }) do |acc, (_, row)|
        if row.tag
          row.tag.each do |tag|
            acc[tag] ||= []
            acc[tag] << row
          end
        else
          acc[:default] << row
        end
        acc
      end
    end

    def match_shortcuts_by_tag(tags, &blk)
      excluded = { :tags => [], :shortcuts => 0 }

      shortcuts_by_tag.each do |tag, rows|
        next if rows.empty?
        unless tag == :default || tags.empty? || tags.include?(tag)
          excluded[:tags] << tag
          excluded[:shortcuts] += rows.length
          next
        end

        yield(tag, rows)
      end

      excluded
    end

    def excluded_output(excluded)
      return if excluded[:tags].empty?

      tags = excluded[:tags].map { |t| '#' + t }.join(', ')
      $stderr.puts "#{excluded[:shortcuts]} shortcut(s) excluded (#{tags})."
    end

    def list_output(row)
      if row.function
        description = row.description || row.command
      else
        description = row.command
      end

      if description
        description = description.split("\n").map(&:strip).join("; ")

        if description.length > 70
          description = description[0...66] + ' ...'
        end
      end

      puts "#{row.shortcut.ljust(20)}          #{description.ljust(70).strip}"
    end

    def generate_output(row)
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

    def parse_row_txt(row, txt)
      if txt =~ /^Shortcut:(.+)$/
        row.shortcut = $1.strip
      end
      if txt =~ %r{^Description:(.+)\nFunction \(y/n\)}m
        row.description = $1.strip if $1.strip.length > 0
      end
      if txt =~ %r{^Function \(y/n\):\s*(y|n)}m
        row.function = ($1.strip == 'y')
      end
      if txt =~ /^Tags:(.+)$/
        row.tag = $1.strip.split(',').map(&:strip)
      end
      if txt =~ /^Command:(.+)$/m
        row.command = $1.strip
      end
    end

    def show_output(row)
      if row.tag
        tags = %{ #{row.tag.map { |t| "##{t}"}.join(', ')}}
      else
        tags = ''
      end
      <<-EOS.gsub(/^        /, '')
        Shortcut: #{row.shortcut}
        Description:
        #{row.description}
        Function: #{row.function ? 'y' : 'n'}
        Tags:#{tags}
        Command:
        #{row.command}
      EOS
    end
  end
end
