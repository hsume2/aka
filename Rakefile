def dump_load_path
  puts $LOAD_PATH.join("\n")
  found = nil
  $LOAD_PATH.each do |path|
    if File.exists?(File.join(path,"rspec"))
      puts "Found rspec in #{path}"
      if File.exists?(File.join(path,"rspec","core"))
        puts "Found core"
        if File.exists?(File.join(path,"rspec","core","rake_task"))
          puts "Found rake_task"
          found = path
        else
          puts "!! no rake_task"
        end
      else
        puts "!!! no core"
      end
    end
  end
  if found.nil?
    puts "Didn't find rspec/core/rake_task anywhere"
  else
    puts "Found in #{path}"
  end
end
require 'bundler'
require 'rake/clean'

require 'rake/testtask'

require 'cucumber'
require 'cucumber/rake/task'
gem 'rdoc' # we need the installed RDoc gem, not the system one
require 'rdoc/task'

include Rake::DSL

Bundler::GemHelper.install_tasks


Rake::TestTask.new do |t|
  t.pattern = 'test/tc_*.rb'
end


CUKE_RESULTS = 'results.html'
CLEAN << CUKE_RESULTS
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format html -o #{CUKE_RESULTS} --format pretty --no-source -x --tags ~@interactive"
  t.fork = false
end

Rake::RDocTask.new do |rd|

  rd.main = "README.rdoc"

  rd.rdoc_files.include("README.rdoc","lib/**/*.rb","bin/**/*")
end

begin
  require 'ronn'

  namespace :man do
    directory "lib/aka/man"

    Dir["man/*.ronn"].each do |ronn|
      basename = File.basename(ronn, ".ronn")
      roff = "lib/aka/man/#{basename}"

      file roff => ["lib/aka/man", ronn] do
        sh "#{Gem.ruby} -S ronn --roff --pipe #{ronn} > #{roff}"
      end

      file "#{roff}.txt" => roff do
        sh "groff -Wall -mtty-char -mandoc -Tascii #{roff} | col -b > #{roff}.txt"
      end

      task :build_all_pages => "#{roff}.txt"
    end

    desc "Build the man pages"
    task :build => "man:build_all_pages"

    desc "Clean up from the built man pages"
    task :clean do
      rm_rf "lib/aka/man"
    end
  end

rescue LoadError
  namespace :man do
    task(:build) { abort "Install the ronn gem to be able to release!" }
    task(:clean) { abort "Install the ronn gem to be able to release!" }
  end
end

task :default => [:test,:features]

