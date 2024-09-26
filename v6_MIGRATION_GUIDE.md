# Migrating to Unleash-Client-Ruby 6.0.0

This guide highlights the key changes you should be aware of when upgrading to v6.0.0 of the Unleash client.

## Custom strategy changes

In version 6+, custom strategies cannot override the built-in strategies. Specifically, strategies `applicationHostname`, `default`, `flexibleRollout`, `gradualRolloutRandom`, `gradualRolloutSessionId`, `gradualRolloutUserId`, `remoteAddress` or `userWithId` throw an error on startup. Previously, creating a custom strategy would only generate a warning in the logs.

The deprecated `register_custom_strategies` method has been removed. You can continue to [register custom strategies](./README.md#custom-strategies) using configuration.

## Direct access to strategy objects

**Note:** If you're not using the method `known_strategies` this section doesn't affect you

The objects for base strategies are no longer directly accessible via the SDK. The `known_strategies` method only returns custom strategies registered by the user. To check if a custom strategy will override either a built-in or custom strategy, use the `includes?` method (returns false if the name is available).

It is strongly discouraged to access or modify any properties of the built-in strategies other than the name. In version 6+, this is a hard requirement.

## ARM requirements

Version 6.0.0 introduces a new dependency on a native binary. Currently, only ARM binaries for macOS are distributed. If you require ARM support for Linux or Windows, please open a GitHub issue.