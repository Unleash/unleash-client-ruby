# Unleash::Client

Unleash client so you can roll out your features with confidence.

Leverage the [Unleash Server](https://github.com/Unleash/unleash) for powerful feature toggling in your ruby/rails applications.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'unleash-client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install unleash-client

### Configure

```
UNLEASH = Unleash::Client.new( hostname: 'foobar.FIXME.domain' )
```

or

```
Unleash::Client.configure do |config|
  config.hostname = 'foobar.FIXME.domain'
end
```

## Usage

```
require 'unleash'
require 'unleash/context'

@unleash = Unleash::Client.new( hostname: 'foobar.FIXME.domain' )

feature_name = "AwesomeFeature"
unleash_context = Unleash::Context.new
unleash_context.user_id = 123

if @unleash.is_enabled?(feature_name, unleash_context)
  puts " #{feature_name} is enabled according to unleash"
else
  puts " #{feature_name} is disabled according to unleash"
end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Local test client

```
bundle exec examples/simple.rb
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rarruda/unleash-client-ruby.

