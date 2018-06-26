# Unleash::Client

Unleash client so you can roll out your features with confidence.

Leverage the [Unleash Server](https://github.com/Unleash/unleash) for powerful feature toggling in your ruby/rails applications.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'unleash', '~> 0.1.0'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install unleash

### Configure

It is required to configure the hostname of the unleash server.

It is highly recommended to configure `app_name` and the `instance_id`.

```ruby
Unleash::Client.configure do |config|
  config.hostname = 'host.domain'
end
```

or instantiate the client with the valid configuration:

```ruby
UNLEASH = Unleash::Client.new(hostname: 'host.domain')
```

## Usage in a plain Ruby Application

```ruby
require 'unleash'
require 'unleash/context'

@unleash = Unleash::Client.new(hostname: 'host.domain')

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

Note: known to not work currently with (puma)[https://github.com/puma/puma].

#### Add Initializer

Put in `config/initializers/unleash.rb`:

```ruby
Unleash::Client.configure do |config|
  config.hostname = 'host.domain'
  config.app_name = Rails.application.class.parent
  # config.instance_id = "#{Socket.gethostname}"
end
```
For `config.instance_id` use a string with a unique identification for the running instance. For example: it could be the hostname, if you only run one App per host. Or the docker image id, if you are running in docker. If it is not set the client will generate an unique UUID for each execution.


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

#### Sample usage

Then wherever in your application that you need a feature toggle, you can use:

```ruby
if UNLEASH.is_enabled? "AwesomeFeature", @unleash_context
  puts "enabled"
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

