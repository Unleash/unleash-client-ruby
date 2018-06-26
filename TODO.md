TODO
====


Implement:
----------
 * ...

To test: (and write tests for)
--------
 * Implement spec test for ruby client specs using https://github.com/Unleash/client-specification/blob/master/05-gradual-rollout-random-strategy.json (similar to the examples below) to ensure consistent client behaviour.
   * java: https://github.com/Unleash/unleash-client-java/compare/master...integration-spec
   * node: https://github.com/Unleash/unleash-client-node/compare/client-specification?expand=1
 * MetricsReporter
 * everything else :)

To consider:
------------
 * Not using class hierarchy for strategies (more duck typing)
 * Compliant to https://github.com/rubocop-hq/ruby-style-guide
 * Remove the extreme amount of comments and logs

DONE:
-----
 * Client registration with the server.
 * Reporter of the status of the feature toggles used.
 * Abstract the Thread/sleep loop with scheduled_executor
 * Thread the Reporter code
 * Tests for All of strategies
 * Configure via yield/blk
 * Configurable Logging (logger + level)
 * Switch hashing function to use murmurhash3 as per https://github.com/Unleash/unleash/issues/247
 * Only report metrics to unleash-server, if there is content in bucket
 * Document usage with Rails

