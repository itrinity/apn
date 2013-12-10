# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'apn/version'

Gem::Specification.new do |spec|
  spec.name          = "apn"
  spec.version       = APN::VERSION
  spec.authors       = ["Peter Hrbacik"]
  spec.email         = ["info@itrinity.com"]
  spec.description   = 'APN is a lightweight Apple Push Notification daemon for Ruby on Rails. APN works asynchronously using Redis and run as a daemon.'
  spec.summary       = 'Asynchronous Apple Push Notification daemon'
  spec.homepage      = "http://github.com/itrinity/apn"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   << "apn"
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency(%q<redis>, ["~> 2.2.2"])
  spec.add_dependency(%q<activesupport>, [">= 0"])
  spec.add_dependency(%q<daemons>, ["= 1.1.6"])
end
