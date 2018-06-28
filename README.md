# Unleash::Client

[![Build Status](https://travis-ci.org/Unleash/unleash-client-ruby.svg?branch=master)](https://travis-ci.org/Unleash/unleash-client-ruby)
[![Coverage Status](https://coveralls.io/repos/github/Unleash/unleash-client-ruby/badge.svg?branch=master)](https://coveralls.io/github/Unleash/unleash-client-ruby?branch=master)

Unleash client so you can roll out your features with confidence.

Leverage the [Unleash Server](https://github.com/Unleash/unleash) for powerful feature toggling in your ruby/rails applications.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'unleash', '~> 0.1.1'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install unleash

## Configure

It is **required** to configure the `url` of the unleash server. Please substitute the sample `'http://unleash.herokuapp.com/api'` for the url of your own instance.

It is **highly recommended** to configure `app_name` and the `instance_id`.

For other options please see `lib/unleash/configuration.rb`.

```ruby
Unleash.configure do |config|
  config.url      = 'http://unleash.herokuapp.com/api'
  config.app_name = 'my_ruby_app'
end
```

or instantiate the client with the valid configuration:

```ruby
UNLEASH = Unleash::Client.new(url: 'http://unleash.herokuapp.com/api', app_name: 'my_ruby_app')
```

## Usage in a plain Ruby Application

```ruby
require 'unleash'
require 'unleash/context'

@unleash = Unleash::Client.new(url: 'http://unleash.herokuapp.com/api', app_name: 'my_ruby_app')

feature_name = "AwesomeFeature"
unleash_context = Unleash::Context.new
unleash_context.user_id = 123

if @unleash.is_enabled?(feature_name, unleash_context)
  puts " #{feature_name} is enabled according to unleash"
else
  puts " #{feature_name} is disabled according to unleash"
end
```

## Usage in a Rails Application

#### Add Initializer

Put in `config/initializers/unleash.rb`:

```ruby
Unleash.configure do |config|
  config.url      = 'http://unleash.herokuapp.com/api'
  config.app_name = Rails.application.class.parent.to_s
  # config.instance_id = "#{Socket.gethostname}"
end

UNLEASH = Unleash::Client.new
```
For `config.instance_id` use a string with a unique identification for the running instance. For example: it could be the hostname, if you only run one App per host. Or the docker container id, if you are running in docker. If it is not set the client will generate an unique UUID for each execution.


#### Add Initializer if using [Puma](https://github.com/puma/puma)

In `puma.rb` ensure that the unleash client is configured and instantiated as below, inside the `on_worker_boot` code block:

```ruby
on_worker_boot do
  # ...

  Unleash.configure do |config|
    config.url      = 'http://unleash.herokuapp.com/api'
    config.app_name = Rails.application.class.parent.to_s
  end
  Rails.configuration.unleash = Unleash::Client.new
end
```

Instead of the configuration in `config/initializers/unleash.rb`.


#### Set Unleash::Context

Be sure to add the following method and callback in the application controller to have `@unleash_context` set for all requests:

Add in `app/controllers/application_controller.rb`:

```ruby
  before_action :set_unleash_context

  private
  def set_unleash_context
    @unleash_context = Unleash::Context.new(
      session_id: session.id,
      remote_address: request.remote_ip,
      user_id: session[:user_id]
    )
  end
```

Or if you see better fit, only in the controllers that you will be using unleash.

#### Sample usage

Then wherever in your application that you need a feature toggle, you can use:

```ruby
if UNLEASH.is_enabled? "AwesomeFeature", @unleash_context
  puts "AwesomeFeature is enabled"
end
```

or if client is set in `Rails.configuration.unleash`:

```ruby
if Rails.configuration.unleash.is_enabled? "AwesomeFeature", @unleash_context
  puts "AwesomeFeature is enabled"
end
```

## Local test client

```
bundle exec examples/simple.rb
```

## Available Strategies

This client comes with the all the required strategies out of the box:

 * ApplicationHostnameStrategy
 * DefaultStrategy
 * GradualRolloutRandomStrategy
 * GradualRolloutSessionIdStrategy
 * GradualRolloutUserIdStrategy
 * RemoteAddressStrategy
 * UnknowndStrategy
 * UserWithIdStrategy


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

See (TODO.md) for known limitations, and feature roadmap.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/unleash/unleash-client-ruby.

Please include tests with any pull requests, to avoid regressions.
