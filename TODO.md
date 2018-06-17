TODO
====


Implement:
----------
 * Thread the Reporter code
 * Abstract the Thread/sleep loop with scheduled_executor
 * Correctly


To test: (and write tests for)
--------
 * All of strategies
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


rails:
```
Unleash::Context.session_id = session.id
Unleash::Context.user_id = current_user.id  # from devise
Unleash::Context.remote_ip = request.env['REMOTE_ADDR']
```