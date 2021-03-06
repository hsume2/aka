require 'optparse'
require 'methadone'

module Aka
  class App
    include Methadone::Main
    include Methadone::CLILogging

    def self.which(executable)
      if File.file?(executable) && File.executable?(executable)
        executable
      elsif ENV['PATH']
        path = ENV['PATH'].split(File::PATH_SEPARATOR).find do |p|
          File.executable?(File.join(p, executable))
        end
        path && File.expand_path(executable, path)
      end
    end

    def self.go!
      setup_defaults
      opts.post_setup
      opts.parse!
      opts.check_args!
      result = call_main
      if result.kind_of? Integer
        exit result
      else
        exit 0
      end
    rescue OptionParser::ParseError => ex
      logger.error ex.message
      puts
      store = Aka::Store.new
      store.help(nil, nil)
      exit 64 # Linux standard for bad command line
    end

    main do |command, shortcut, script|
      if options[:version]
        puts "aka version #{Aka::VERSION}"
        exit
      end

      options['shortcut'] = options[:shortcut] = shortcut
      options['command'] = options[:command] = script

      store = Aka::Store.new

      if options[:help]
        store.help(command, options)
        exit
      end

      case command
      when 'add'
        store.add(options)
      when 'list'
        store.list(options)
      when 'remove'
        store.remove(options)
      when 'generate'
        store.generate(options)
      when 'edit'
        store.edit(options)
      when 'show'
        store.show(options)
      when 'link'
        if shortcut == 'delete'
          store.unlink(script.to_i)
        else
          store.link(options)
        end
      when 'upgrade'
        store.upgrade(options)
      when 'sync'
        store.sync(shortcut ? shortcut.to_i : nil)
      else
        store.help(command, options)
        exit
      end
    end

    arg :command, :optional
    arg :shortcut, :optional
    arg :script, :optional

    on("-t TAG", '--tag', Array)
    on("-f", '--force')
    on("-F", "--function")
    on("-d DESCRIPTION", "--description")
    on("-o FILE", "--output")
    on("-i FILE", "--input")
    on("-h", "--help")
    on("-v", "--version")
    on("--delete")

    use_log_level_option
  end
end
