
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Note: These changes are not considered notable:
- build
- documentation
- dependencies

## [Unreleased]

## [5.0.0] - 2023-10-30
### Added
- change seed for variantutils to ensure fair distribution (#160)
  - client specification is [here](https://github.com/Unleash/client-specification/tree/v5.0.2/specifications)
  - A new seed is introduced to ensure a fair distribution for variants, addressing the issue of skewed variant distribution due to using the same hash string for both gradual rollout and variant allocation.

## [4.6.0] - 2023-10-16
### Added
- dependant toggles (#155)
  - client specification is [here](https://github.com/Unleash/client-specification/pull/63)

## [4.5.0] - 2023-07-05
### Added
- variants in strategies (#148)
  - issue described here (#147)

### Fixed
- groupId override for variants

## [4.4.4] - 2023-07-05
### Fixed
- flexible rollout strategy without context (#146)
  - The flexible rollout strategy should evaluate default and random stickiness even if context is not provided.

## [4.4.3] - 2023-06-14
### Added
- Add Context#to_h method (#136)

### Fixed
- Bootstrapped variants now work when client is disabled (#138)
- Variant metrics are now sent correctly to Unleash. Fixed a typo in the payload name. (#145)

### Changed
- Automatically disable metrics/MetricsReporter when client is disabled (#139) (#140)

## [4.4.2] - 2023-01-05
### Added
- Add Client#disabled? method (#130)

## [4.4.1] - 2022-12-07
### Fixed
- exception no longer bubbles up in constraints when context is nil (#127)
- variants metrics did count toggles correctly  (#126)
- prevent race condition when manipulating metrics data  (#122)
- allow passing user_id as integer (#119)

## [4.4.0] - 2022-09-19
### Added
- Allow custom strategies (#96)
- Global segments (#114)

### Fixed
- Initializing client configuration from constructor (#117)
- Support int context in set comparison (#115)

## [4.3.0] - 2023-07-14
### Added
- dynamic http headers via Proc or Lambda (#107)

### Fixed
- Fixed ToggleFetcher#save! to close opened files on failure. (#97)

### Changed
- Refactored ToggleFetcher#read! (#106)

## [4.2.1] - 2022-03-29
### Fixed
- correct logic for default values on feature toggles so toggle value respected when toggle exists and default is true (#93)

## [4.2.0] - 2022-03-18
### Added
- Advanced constraints operators (#92)

### Changed
- Default to the client never giving up trying to reach the server even after repeated failures (#91)

## [4.1.0] - 2022-02-11
### Added
- feat: Implement custom bootstrapping on startup (#88)
- feat: add support for cidr in `RemoteAddress` strategy (#77)

### Changed
- default values for `metrics_interval` to `60s` and `retry_limit` to `5` (#78)

## [4.0.0] - 2021-12-16
### Added
- Support for projects query (requires unleash 4.x) (#38)
- Allow passing blocks to is_enabled? to determine default_result (#33)
- Implement custom stickiness (#69)
- Allow using custom_http_headers from the CLI utility (#75)

### Fixed
- Allow context to correctly resolve camelCase property values (#74)
- Avoid unlikely situation of config changing under the read operation due to backup path file being incorrectly set (#63)

### Changed
- change how we handle the server api url (avoid double slashes in urls used for API calls.)
- default values: refresh_interval => 10, metrics_interval=> 30 (#59)
- changed metrics reporting behavior (#66)
- only send metrics if there is data to send. (#58)
- in Client#get_variant() allow context and fallback_variant as nil (#51)

[unreleased]: https://git1hub.com/unleash/unleash-client-ruby/compare/v4.4.3...HEAD
[4.4.3]: https://github.com/unleash/unleash-client-ruby/compare/v4.4.2...v4.4.3
[4.4.2]: https://github.com/unleash/unleash-client-ruby/compare/v4.4.1...v4.4.2
[4.4.1]: https://github.com/unleash/unleash-client-ruby/compare/v4.4.0...v4.4.1
[4.4.0]: https://github.com/unleash/unleash-client-ruby/compare/v4.3.0...v4.4.0
[4.3.0]: https://github.com/unleash/unleash-client-ruby/compare/v4.2.1...v4.3.0
[4.2.1]: https://github.com/unleash/unleash-client-ruby/compare/v4.2.0...v4.2.1
[4.2.0]: https://github.com/unleash/unleash-client-ruby/compare/v4.1.0...v4.2.0
[4.1.0]: https://github.com/unleash/unleash-client-ruby/compare/v4.0.0...v4.1.0
[4.0.0]: https://github.com/unleash/unleash-client-ruby/compare/v3.2.5...v4.0.0
