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
        aka-link.1
        aka-sync.1
        aka-upgrade.1
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
      found = configuration.shortcuts.find(options)

      if found.length > 0
        unless options[:force]
          abort %{Shortcut "#{options[:shortcut]}" exists. Pass --force to overwrite. Or provide a new --tag.}
        else
          found.each do |n, row|
            configuration.shortcuts.replace(n, Configuration::Shortcut.parse(options))
          end
          configuration.save
          puts "Overwrote shortcut."
        end
      else
        configuration.shortcuts.append(Configuration::Shortcut.parse(options))
        configuration.save
        puts "Created shortcut."
      end
    end

    def list(options)
      excluded = configuration.shortcuts.match_by_tag(options[:tag] || []) do |tag, rows|
        puts %{##{tag}}
        puts ''.ljust(tag.length + 1, '=')
        rows.each do |row|
          list_output(row)
        end
        puts
      end

      if configuration.links.any?
        puts "====="
        puts "Links"
        puts "====="
        puts

        configuration.links.each do |link|
          puts "#{link.output}: #{link.tag.map { |tag| "##{tag}" }.join(', ')}"
        end
      end

      excluded_output(excluded)
    end

    def remove(options)
      found = configuration.shortcuts.find(options)

      if found.length > 0
        found.each do |n, row|
          configuration.shortcuts.delete(n)
        end

        configuration.save

        puts "Removed shortcut."
      else
        abort %{No shortcut "#{options[:shortcut]}". Aborting.}
      end
    end

    def generate(options)
      excluded = configuration.shortcuts.generate(options)

      excluded_output(excluded)
    end

    def link(options)
      unless options[:delete]
        configuration.links.add(options)
        configuration.save
        puts "Saved link."
      else
        configuration.links.delete(options)
        configuration.save
        puts "Deleted link."
      end
    end

    def sync
      configuration.links.each do |config|
        excluded = configuration.shortcuts.generate(config)
        excluded_output(excluded)
      end
    end

    def edit(options)
      result = nil

      found = configuration.shortcuts.find(options)

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
        configuration.shortcuts.replace(index, row)
        configuration.save
        puts "Saved shortcut."
      else
      end
    end

    def show(options)
      found = configuration.shortcuts.find(options)

      _, row = found.first

      if row
        puts show_output(row)
      else
        abort "Shortcut not found."
      end
    end

    def upgrade(options)
      configuration.upgrade
    end

    private

    def configuration
      @configuration ||= Configuration.new
    end

    def shortcuts
      configuration.shortcuts.all
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
