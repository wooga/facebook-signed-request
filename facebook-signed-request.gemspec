# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "facebook-signed-request/version"

Gem::Specification.new do |s|
  s.name        = "facebook-signed-request"
  s.version     = Facebook::SignedRequest::VERSION
  s.authors     = ["hukl"]
  s.email       = ["contact@smyck.org"]
  s.homepage    = ""
  s.summary     = %q{Parses and validates Facebook signed requests}
  s.description = %q{Parses and validates Facebook signed requests}

  s.rubyforge_project = "facebook-signed-request"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
