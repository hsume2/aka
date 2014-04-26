module Aka
  module Upgrader
    module FromV0ToV1
      def self.run(aka_yml)
        v0 = YAML::load_file(aka_yml)

        current = {
          :version => '1',
          :shortcuts => v0
        }

        FileUtils.cp(aka_yml, "#{aka_yml}.backup")
        puts "Backed up to #{aka_yml}.backup."

        File.open(aka_yml, 'w+') do |f|
          f.write current.to_yaml
        end
        puts "Upgraded #{aka_yml}."
      end
    end

    module FromV1ToV2
      def self.run(aka_yml, aka_link_yml)
        v1 = YAML::load_file(aka_yml)

        v2 = v1.merge(:version => '2')
        links = v2.delete(:links)

        FileUtils.cp(aka_yml, "#{aka_yml}.backup")
        puts "Backed up to #{aka_yml}.backup."

        File.open(aka_yml, 'w+') do |f|
          f.write v2.to_yaml
        end
        puts "Upgraded #{aka_yml}."

        v2_links = {
          :version => '2',
          :links => links
        }

        File.open(aka_link_yml, 'w+') do |f|
          f.write v2_links.to_yaml
        end
        puts "Created #{aka_link_yml}."
      end
    end
  end
end
