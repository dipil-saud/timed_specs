# -*- encoding: utf-8 -*-
require File.expand_path('../lib/timed_specs/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["dipil-saud"]
  gem.email         = ["dipil.saud@gmail.com"]
  gem.description   = %q{
    A Rspec formatter built upon the default DocumentationFormatter which shows the time taken for each example along with the other information shown by the DocumentationFormatter. You also have the option to list the slowest 'n' examples at the end.
  }
  gem.summary       = %q{A rspec formatter which displays the individual time taken by each example and lists the slowest examples. }
  gem.homepage      = "https://github.com/dipil-saud/timed_specs"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "timed_specs"
  gem.require_paths = ["lib"]
  gem.version       = VERSION

  gem.add_runtime_dependency "rspec"
  gem.add_development_dependency "pry"
end
