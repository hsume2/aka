module Aka
  module Upgrader
    module FromV0
      def self.run(aka_yml)
        v0 = YAML::load_file(aka_yml)

        current = {
          :version => Aka::Configuration::FORMAT,
          :shortcuts => v0
        }

        File.open(aka_yml, 'w+') do |f|
          f.write current.to_yaml
        end
      end
    end
  end
end
