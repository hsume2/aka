module Aka
  module Upgrader
    module FromV0To1
      def self.run(aka_yml)
        v0 = YAML::load_file(aka_yml)

        current = {
          :version => '1',
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

    module FromV1To2
      def self.run(aka_yml, aka_link)
        v1 = YAML::load_file(aka_yml)
        v1[:version] = '2'

        links = v1.delete(:links)

        FileUtils.cp(aka_yml, "#{aka_yml}.backup")

        File.open(aka_yml, 'w+') do |f|
          f.write v1.to_yaml
        end

        File.open(aka_link, 'w+') do |f|
          f.write links.to_yaml
        end if links.any?

        puts "Upgraded #{aka_yml}."
        puts "Backed up to #{aka_yml}.backup."
      end
    end
  end
end
