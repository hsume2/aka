module Aka
  module Upgrader
    module FromV0
      def self.run(aka_yml)
        v0 = YAML::load_file(aka_yml)

        current = {
          :version => Aka::Configuration::FORMAT,
          :shortcuts => v0
        }

        FileUtils.cp(aka_yml, "#{aka_yml}.backup")

        File.open(aka_yml, 'w+') do |f|
          f.write current.to_yaml
        end

        puts "Upgraded #{aka_yml}."
        puts "Backed up to #{aka_yml}.backup."
      end
    end
  end
end
