# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aka/version'

Gem::Specification.new do |spec|
  spec.name          = "aka"
  spec.version       = Aka::VERSION
  spec.authors       = ["Henry Hsu"]
  spec.email         = ["hhsu@zendesk.com"]
  spec.summary       = %q{Manage Shell Keyboard Shortcuts}
  spec.description   = %q{Manage Shell Keyboard Shortcuts}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.files        += Dir.glob('lib/aka/man/**/*') # man/ is ignored by git
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency('rdoc')
  spec.add_development_dependency('aruba')
  spec.add_development_dependency('rake', '~> 0.9.2')
  spec.add_development_dependency('guard')
  spec.add_development_dependency('guard-cucumber')
  spec.add_development_dependency('ronn')
  spec.add_dependency('methadone', '~> 1.3.1')
end
