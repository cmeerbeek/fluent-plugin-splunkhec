# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-splunkhec"
  gem.version       = "2.3"
  gem.authors       = "Coen Meerbeek"
  gem.email         = "cmeerbeek@gmail.com"
  gem.description   = %q{Output plugin for the Splunk HTTP Event Collector.}
  gem.homepage      = "https://github.com/cmeerbeek/fluent-plugin-splunkhec"
  gem.summary       = %q{This plugin allows you to sent events to the Splunk HTTP Event Collector.}

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "fluentd", [">= 1.15.1", "< 2"]
  gem.add_dependency "yajl-ruby", '>= 1.4.3'
  gem.add_development_dependency "rake", '>= 13.0.6'
  gem.add_development_dependency "test-unit", '~> 3.5', '>= 3.5.3'
  gem.add_development_dependency "webmock", '>= 3.14.0'
  gem.license = 'MIT'
end
