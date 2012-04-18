# -*- encoding: utf-8 -*-
require File.expand_path('../lib/calendrier/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Romain Castel"]
  gem.email         = ["romain.castel@lafourmi-immo.com"]
  gem.description   = %q{simple calendar}
  gem.summary       = %q{simple calendar ...}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "calendrier"
  gem.require_paths = ["lib"]
  gem.version       = Calendrier::VERSION
end
