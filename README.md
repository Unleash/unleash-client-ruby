# Unleash::Client

[![Build Status](https://travis-ci.org/Unleash/unleash-client-ruby.svg?branch=master)](https://travis-ci.org/Unleash/unleash-client-ruby)
[![Coverage Status](https://coveralls.io/repos/github/Unleash/unleash-client-ruby/badge.svg?branch=master)](https://coveralls.io/github/Unleash/unleash-client-ruby?branch=master)

Unleash client so you can roll out your features with confidence.

Leverage the [Unleash Server](https://github.com/Unleash/unleash) for powerful feature toggling in your ruby/rails applications.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'unleash', '~> 0.1.4'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install unleash

## Configure

It is **required** to configure the `url` of the unleash server and `app_name` with the name of the runninng application. Please substitute the sample `'http://unleash.herokuapp.com/api'` for the url of your own instance.

It is **highly recommended** to configure the `instance_id` parameter as well.


```ruby
Unleash.configure do |config|
  config.url         = 'http://unleash.herokuapp.com/api'
  config.app_name    = 'my_ruby_app'
end
```

or instantiate the client with the valid configuration:

```ruby
UNLEASH = Unleash::Client.new(url: 'http://unleash.herokuapp.com/api', app_name: 'my_ruby_app')
```

#### List of Arguments

Argument | Description | Required? |  Type |  Default Value|
---------|-------------|-----------|-------|---------------|
`url`      | Unleash server URL. | Y | String | N/A |
`app_name` | Name of your program. | Y | String | N/A |
`instance_id` | Identifier for the running instance of program. Important so you can trace back to where metrics are being collected from. **Highly recommended be be set.** | N | String | random UUID |
`refresh_interval` | How often the unleash client should check with the server for configuration changes. | N | Integer |  15 |
`metrics_interval` | How often the unleash client should send metrics to server. | N | Integer | 10 |
`disable_client` | Disables all communication with the Unleash server. Defeats the entire purpose of using unleash, but can be useful in when running tests. | N | Boolean | F |
`disable_metrics` | Disables sending metrics to Unleash server. | N | Boolean | F |
`custom_http_headers` | Custom headers to send to Unleash. | N | Hash | {} |
`timeout` | How long to wait for the connection to be established or wait in reading state (open_timeout/read_timeout) | N | Integer | 30 |
`retry_limit` | How many consecutive failures in connecting to the Unleash server are allowed before giving up. | N | Integer | 1 |
`backup_file` | Filename to store the last known state from the Unleash server. Best to not change this from the default. | N | `Dir.tmpdir + "/unleash-#{app_name}-repo.json` |
`logger` | Specify a custom `Logger` class to handle logs from the client. | N | `Logger.new(STDOUT)` |
`log_level` | Change the log level for the `Logger` class. | N | `Logger::ERROR` |

For in a more in depth look, please see `lib/unleash/configuration.rb`.


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
 * UnknownStrategy
 * UserWithIdStrategy


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

See [TODO.md](TODO.md) for known limitations, and feature roadmap.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/unleash/unleash-client-ruby.

Please include tests with any pull requests, to avoid regressions.
