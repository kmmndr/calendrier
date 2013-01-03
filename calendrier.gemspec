# -*- encoding: utf-8 -*-
require File.expand_path('../lib/calendrier/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Thomas Kienlen", "Romain Castel"]
  gem.email         = ["thomas.kienlen@lafourmi-immo.com"]
  gem.description   = %q{simple calendar}
  gem.summary       = %q{simple calendar gem, including helpers to display objects inside cells}
  gem.homepage      = "https://github.com/lafourmi/calendrier"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "calendrier"
  gem.require_paths = ["lib"]
  gem.add_dependency 'rails', ['>= 3.0']
  gem.version       = Calendrier::VERSION
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'nokogiri'
  unless ENV["CI"]
    gem.add_development_dependency "turn", "~> 0.9" if defined?(RUBY_VERSION) && RUBY_VERSION > '1.9'
  end
end
