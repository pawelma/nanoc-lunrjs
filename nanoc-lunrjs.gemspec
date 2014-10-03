# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nanoc-lunrjs/version'

Gem::Specification.new do |spec|
  spec.name          = "nanoc-lunrjs"
  spec.version       = NanocLunrjs::VERSION
  spec.authors       = ["Paweł Madejski"]
  spec.email         = ["pmadejski@cubiware.com"]
  spec.summary       = %q{Tool that enable full text search through static pages}
  spec.description   = %q{NanocLunrjs is gem that enables lunrjs 'full' text search through static bages. Search is based on created index.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'haml'
  spec.add_dependency 'json'
  spec.add_dependency 'nanoc', '>= 3.7.0'
  spec.add_dependency 'nokogiri'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
