require 'yaml'
require 'ostruct'
require 'tempfile'
require 'methadone'

module Aka
  class Store
    include Methadone::CLILogging

    FORMAT = '3'

    def help(command, options)
      case command
      when nil       then command = "aka.7"
      when 'ls'      then command = "aka.list.1"
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
      end
    end

    def add(options)
      shortcut = Configuration::Shortcut.new({
        :shortcut => options[:shortcut],
        :command => options[:command],
        :tag => options[:tag] || [],
        :description => options[:description],
        :function => options[:function]
      })

      found = shortcut_manager.find(options)
      if found.length > 0
        unless options[:force]
          abort %{Shortcut "#{options[:shortcut]}" exists. Pass --force to overwrite. Or provide a new --tag.}
        else
          found.each do |row|
            [:shortcut, :command, :description, :function].each do |key|
              row.send(:"#{key}=", options[key])
            end
            row.tag = options[:tag] || []
          end
          save
          puts "Overwrote shortcut."
        end
      else
        shortcut_manager.add(shortcut)
        save
        puts "Created shortcut."
      end
    end

    def list(options)
      excluded = shortcut_manager.match_by_tag(options[:tag] || []) do |tag, rows|
        puts %{##{tag}}
        puts ''.ljust(tag.length + 1, '=')
        rows.each do |row|
          list_output(row)
        end
        puts
      end

      if link_manager.any?
        puts "====="
        puts "Links"
        puts "====="
        puts

        index = 1
        link_manager.each do |link|
          puts "[#{index}] #{link.output}: #{link.tag.map { |tag| "##{tag}" }.join(', ')}"
          index += 1
        end
      end

      excluded_output(excluded)
    end

    def remove(options)
      found = shortcut_manager.find(options)

      if found.length > 0
        found.each do |shortcut|
          shortcut_manager.remove(shortcut)
        end

        save

        puts "Removed shortcut."
      else
        abort %{No shortcut "#{options[:shortcut]}". Aborting.}
      end
    end

    def generate(options)
      excluded = shortcut_manager.generate(options)

      excluded_output(excluded)
    end

    def link(options)
      unless options[:tag] && options[:output]
        abort("Invalid link.")
      end

      new_link = Configuration::Link.new({
        :tag => options[:tag],
        :output => options[:output]
      })

      link_manager.add(new_link)
      save
      puts "Saved link."
    end

    def unlink(key)
      link_manager.remove(key)
      save
      puts "Deleted link."
    end

    def sync(match)
      index = 0
      link_manager.each do |config|
        index += 1
        next if match && match != index
        excluded = shortcut_manager.generate({ :tag => config.tag, :output => config.output })
        excluded_output(excluded)
      end
    end

    def edit(options)
      result = nil

      row = shortcut_manager.find(options).first

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
            Shortcut: #{row.shortcut}
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
        save
        puts "Saved shortcut."
      else
      end
    end

    def show(options)
      row = shortcut_manager.find(options).first

      if row
        puts show_output(row)
      else
        abort "Shortcut not found."
      end
    end

    def upgrade(options)
      configuration

      if !@version
        Upgrader::FromV0ToV1.run(aka_db)
      elsif @version == '1'
        Upgrader::FromV1ToV2.run(aka_db)
      elsif @version == '2'
        Upgrader::FromV2ToV3.run(aka_db)
      end
    end

    def save
      File.open(aka_db, 'w+') do |f|
        f.write configuration.encode
      end
    end

    private

    def configuration
      @configuration ||= begin
        if File.exist?(aka_db)
          begin
            Configuration.decode(File.read(aka_db))
          rescue Protobuf::InvalidWireType => e
            YAML::load_file(aka_db).tap do |result|
              if result[:version]
                @version = result[:version]
              end
            end
            Configuration.new(:version => @version)
          end
        else
          Configuration.new(:version => FORMAT)
        end
      end
    end

    def shortcut_manager
      @shortcuts ||= ShortcutManager.new(configuration.shortcuts)
    end

    def link_manager
      @link_manager ||= LinkManager.new(configuration.links)
    end

    def aka_db
      ENV['AKA'] || File.expand_path('~/.aka.db')
    end

    def excluded_output(excluded)
      return if excluded[:tags].empty?

      tags = excluded[:tags].map { |t| '#' + t }.join(', ')
      $stderr.puts "#{excluded[:shortcuts]} shortcut(s) excluded (#{tags})."
    end

    def list_output(row)
      description = row.description.length > 0 ? row.description : row.command

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
      if txt =~ /^Tags:(.*)$/
        row.tag = $1.strip.split(',').map(&:strip)
      end
      if txt =~ /^Command:(.*)$/m
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
