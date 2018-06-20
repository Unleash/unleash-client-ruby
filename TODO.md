TODO
====


Implement:
----------
 * Document on using it with Rails


To test: (and write tests for)
--------
 * everything else :)

To consider:
------------
 * Not using class hierarchy for strategies
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

Rails:
```
Unleash::Context.session_id = session.id
Unleash::Context.user_id = current_user.id  # from devise
Unleash::Context.remote_ip = request.env['REMOTE_ADDR']
```