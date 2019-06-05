module Aka
  module Upgrader
    module FromV0ToV1
      def self.run(aka_db)
        v0 = YAML::load_file(aka_db)

        current = {
          :version => '1',
          :shortcuts => v0
        }

        FileUtils.cp(aka_db, "#{aka_db}.backup")
        puts "Backed up to #{aka_db}.backup."

        File.open(aka_db, 'w+') do |f|
          f.write current.to_yaml
        end
        puts "Upgraded #{aka_db}."
      end
    end

    module FromV1ToV2
      def self.run(aka_db)
        v1 = YAML::load_file(aka_db)

        v2 = v1.merge(:version => '2')
        links = v2.delete(:links)
        v2[:links] = new_links = {}
        if links
          index = 0
          links.each do |element|
            index += 1
            new_links[index] = element
          end
        end

        FileUtils.cp(aka_db, "#{aka_db}.backup")
        puts "Backed up to #{aka_db}.backup."

        File.open(aka_db, 'w+') do |f|
          f.write v2.to_yaml
        end
        puts "Upgraded #{aka_db}."
      end
    end

    module FromV2ToV3
      def self.run(aka_db)
        v2 = YAML::load_file(aka_db)

        v3 = Configuration.new(:version => '3')

        v2[:shortcuts].each do |_, shortcut|
          v3.shortcuts << Configuration::Shortcut.new({
            :shortcut => shortcut[:shortcut],
            :command => shortcut[:command],
            :tag => shortcut[:tag],
            :description => shortcut[:description],
            :function => shortcut[:function]
          })
        end

        (v2[:links] || {}).each do |_, link|
          v3.links << Configuration::Link.new({
            :tag => link[:tag],
            :output => link[:output]
          })
        end

        FileUtils.cp(aka_db, "#{aka_db}.backup")
        puts "Backed up to #{aka_db}.backup."

        File.open(aka_db, 'w+') do |f|
          f.write Configuration.encode(v3)
        end
        puts "Upgraded #{aka_db}."
      end
    end
  end
end
