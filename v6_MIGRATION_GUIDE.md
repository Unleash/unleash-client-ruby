# Migrating to Unleash-Client-Ruby 6.0.0

The upgrade the v6.0.0 of the Unleash client should be mostly seamless. There are a few significant changes that may require some changes on the consumer side or that the consumer should be generally aware of.

## Custom strategy changes

There's a few changes to custom strategies that may affect you if you make heavy use of them.

Firstly, custom strategies are no longer allowed to override the built in strategies, namely custom strategies named 'applicationHostname', 'default', 'flexibleRollout', 'gradualRolloutRandom', 'gradualRolloutSessionId', 'gradualRolloutUserId', 'remoteAddress' or 'userWithId' will now raise an error on startup, whereas previously creating a custom strategy with one of these names would raise a warning in the logs.

Secondly, the deprecated `register_custom_strategies` method has now been removed. The only way to register a custom strategy is to use configuration, i.e.

```ruby
class MyCustomStrategy
  def name
    'myCustomStrategy'
  end

  def is_enabled?(params = {}, context = nil)
    true
  end
end

Unleash.configure do |config|
  config.strategies.add(MyCustomStrategy.new)
end
```

If you're already using configuration to register your custom strategies and you're not overriding the default strategies, this section doesn't affect you.

## Direct access to strategy objects

The objects for base strategies are no longer directly accessible via the SDK, the `known_strategies` method will only return custom strategies registered by the user. If you need to know whether or not a custom strategy will override either a built in or custom strategy, the `includes?` method will return a false if the name is available.

Generally, it's strongly discouraged to access or alter any of the strategy properties other than the name for built in strategies. v.6.0.0 makes this a hard requirement.

## ARM requirements

v6.0.0 has a new dependency on a native binary; we currently only distribute ARM binaries for MacOS. If you need ARM support on Linux or Windows, please feel free to open an issue.