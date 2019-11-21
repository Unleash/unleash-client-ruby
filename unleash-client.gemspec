lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'unleash/version'

Gem::Specification.new do |spec|
  spec.name          = "unleash"
  spec.version       = Unleash::VERSION
  spec.authors       = ["Renato Arruda"]
  spec.email         = ["rarruda@rarruda.org"]
  spec.licenses      = ["Apache-2.0"]

  spec.summary       = "Unleash feature toggle client."
  spec.description   = "This is the ruby client for Unleash, a powerful feature toggle system
    that gives you a great overview over all feature toggles across all your applications and services."

  spec.homepage      = "https://github.com/unleash/unleash-client-ruby"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = "~> 2.3"

  spec.add_dependency "murmurhash3", "~> 0.1.6"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-json_expectations", "~> 2.1"
  spec.add_development_dependency "webmock", "~> 3.0"

  spec.add_development_dependency "coveralls", "~> 0.8"
  spec.add_development_dependency "rubocop", "~> 0.72"
end
