# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "state_event/version"

Gem::Specification.new do |s|
  s.name        = "state_event"
  s.version     = StateEvent::VERSION
  s.authors     = ["Brian Leonard"]
  s.email       = ["brian@bleonard.com"]
  s.homepage    = ""
  s.summary     = %q{A state machine with logging}
  s.description = %q{A state machine with logging}

  s.rubyforge_project = "state_event"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'aasm', '2.1.4'

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
