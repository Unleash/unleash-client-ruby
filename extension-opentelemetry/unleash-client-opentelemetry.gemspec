lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require '../lib/unleash/version'

Gem::Specification.new do |spec|
  spec.name          = "unleash-opentelemetry"
  spec.version       = Unleash::VERSION
  spec.authors       = ["Renato Arruda"]
  spec.email         = ["rarruda@rarruda.org"]
  spec.licenses      = ["Apache-2.0"]

  spec.summary       = "Unleash feature toggle client with HTTP calls wrapped in opentelemetry spans."
  spec.description   = "This is the ruby client for Unleash, a powerful feature toggle system
    that gives you a great overview over all feature toggles across all your applications and services.

    In this client we wrap all HTTP calls with opentelemetry spans, to make it easier to debug when tracing.
"

  spec.homepage      = "https://github.com/unleash/unleash-client-ruby"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 3.0"

  spec.add_dependency "unleash", Unleash::VERSION
  spec.add_dependency "opentelemetry-api", "~> 1.0"

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rspec", "~> 3.12"

end
