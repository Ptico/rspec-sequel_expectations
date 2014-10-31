# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/sequel_expectations/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec-sequel_expectations"
  spec.version       = Rspec::SequelExpectations::VERSION
  spec.authors       = ["Andrey Savchenko"]
  spec.email         = ["andrey@aejis.eu"]
  spec.summary       = %q{RSpec matchers for Sequel}
  spec.description   = %q{RSpec matchers for Sequel which tests database, not model}
  spec.homepage      = "https://github.com/Ptico/rspec-sequel_expectations"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "sequel", "~> 4.8"
  spec.add_dependency "rspec-expectations", "~> 3.0"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "sequel_pg"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "faker"
end
