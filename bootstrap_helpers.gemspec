# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bootstrap_helpers/version'

Gem::Specification.new do |spec|
  spec.name          = "bootstrap_helpers"
  spec.version       = BootstrapHelpers::VERSION
  spec.authors       = ["Nicola Racco"]
  spec.email         = ["nicola@nicolaracco.com"]
  spec.description   = %q{minimal bootstrap 3.0 helpers}
  spec.summary       = %q{minimal bootstrap 3.0 helpers}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency "rails", ">= 3.0"
end
