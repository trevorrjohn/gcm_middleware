# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gcm_middleware/version'

Gem::Specification.new do |spec|
  spec.name          = "gcm_middleware"
  spec.version       = GCMMiddleware::VERSION
  spec.authors       = ["Trevor John"]
  spec.email         = ["trevor@john.tj"]
  spec.summary       = %q{A collection of faraday middleware for Google Cloud Messaging}
  spec.description   = %q{Adds authentication key and stores original device registration ids on requests}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'faraday'
  spec.add_dependency 'faraday_middleware'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1"
end
