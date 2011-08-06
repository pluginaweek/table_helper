$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'table_helper/version'

Gem::Specification.new do |s|
  s.name              = "table_helper"
  s.version           = TableHelper::VERSION
  s.authors           = ["Aaron Pfeifer"]
  s.email             = "aaron@pluginaweek.org"
  s.homepage          = "http://www.pluginaweek.org"
  s.description       = "Adds a helper method for generating HTML tables from collections in Rails"
  s.summary           = "HTML tables from collections in Rails"
  s.require_paths     = ["lib"]
  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files -- test/*`.split("\n")
  s.rdoc_options      = %w(--line-numbers --inline-source --title table_helper --main README.rdoc)
  s.extra_rdoc_files  = %w(README.rdoc CHANGELOG.rdoc LICENSE)
  
  s.add_development_dependency("rake")
  s.add_development_dependency("plugin_test_helper", ">= 0.3.2")
end
