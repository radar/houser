# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'houser/version'

Gem::Specification.new do |spec|
  spec.name          = "houser"
  spec.version       = Houser::VERSION
  spec.authors       = ["Ryan Bigg"]
  spec.email         = ["radarlistener@gmail.com"]
  spec.summary       = %q{Lightweight multitenancy gem.}
  spec.description   = %q{Lightweight multitenancy gem.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rack"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec-rails", "2.99.0.beta1"
  spec.add_development_dependency "pry"
end
