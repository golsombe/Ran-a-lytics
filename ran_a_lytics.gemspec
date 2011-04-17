# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ran_a_lytics/version"

Gem::Specification.new do |s|
  s.name        = "ran_a_lytics"
  s.version     = RanALytics::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = "Robert Hall"
  s.email       = "robert.hall@itatc.com"
  s.homepage    = "http://github.com/golsombe/ran_a_lytics"
  s.summary     = "An Infobright compainion Rails extention"
  s.description = "Providing analytics as a DSL to an InfobrightCE database"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project = "ran_a_lytics"

  s.add_dependency "activerecord", ">= 3.0.0"
  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rspec", ">= 2.0.0"
  s.add_development_dependency "database_cleaner", "0.5.2"
  s.add_development_dependency "mysql", ">= 2.8.1"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
