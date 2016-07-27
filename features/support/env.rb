require 'aruba/cucumber'
require 'methadone/cucumber'
require 'aruba/in_process'

ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"
LIB_DIR = File.join(File.expand_path(File.dirname(__FILE__)),'..','..','lib')

require 'aka.rb'

class Main
  def initialize(argv, stdin = STDIN, stdout = STDOUT, stderr = STDERR, kernel = Kernel)
    @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
  end

  def execute!
    original_file = $0
    original_argv = ::ARGV.dup
    original_stderr = $original_stderr = $stderr
    original_stdin = $original_stdin = $stdin
    original_stdout = $stdout

    Aruba::Api.class_eval do
      def announcer
        Aruba::Api::Announcer.new(self,
          :stdout => $original_stdin,
          :stderr => $original_stderr,
          :dir => @announce_dir,
          :cmd => @announce_cmd,
          :env => @announce_env)
      end
    end

    begin
      $0 = File.expand_path(File.dirname(__FILE__) + '/../../bin/aka')

      ::ARGV.clear
      ::ARGV.push(*@argv)

      $stderr = @stderr
      $stdin = @stdin
      $stdout = @stdout

      if defined?(Aka::App)
        Aka::App.send(:reset!)
        load 'aka/app.rb'
      end

      Aka::App.change_logger(Methadone::CLILogger.new(@stdout, @stderr))

      Aka::App.go!
    rescue SystemExit => e
      @kernel.exit(e.status)
    ensure
      $0 = original_file

      ::ARGV.clear
      ::ARGV.push(*original_argv)

      $stderr = original_stderr
      $stdin = original_stdin
      $stdout = original_stdout

      Aka::App.change_logger(Methadone::CLILogger.new($stdout, $stderr))
    end
  end
end

Aruba.configure do |config|
  config.main_class = Main
  config.command_launcher = :in_process
end

Before do
  # Using "announce" causes massive warnings on 1.9.2
  @puts = true
  @original_rubylib = ENV['RUBYLIB']
  ENV['RUBYLIB'] = LIB_DIR + File::PATH_SEPARATOR + ENV['RUBYLIB'].to_s
end

After do
  ENV['RUBYLIB'] = @original_rubylib
end
