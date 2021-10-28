## 2.2

Replaced deprecated packet statement

## 2.1

Replaced yajl/json_ge for regular yajl

## 2.0

Migrate to use FluentD v1 API. It doesn't support backwards compatibility.

## 1.9

Reverted source and sourcetpye settings. They now reflect the README.

## 1.8

- Add expand function used in ES plugin an get variables from kubernetes tags in fluent.conf

## 1.7

- Fixed HTTP request (removed verify none)
- udpated testscript
- implemented travis.yml

## 1.6

- changed tag from sourcetype to source
- improved ruby net HTTP implementation

## 1.5

- changed yajl dependency to yajl-ruby 1.3.0 or above
- fixed typo in readme

## 1.4

Fixed undefined conversion error from ASCII-8BIT to UTF-8 by swapping json gem for yajl as used by fluentd

## 1.3

In case of error in the connection exception is raised and fluent will retry.

## 1.2

- Improved unit test coverage
- Removed superfluous instance variables
- Added feature send_batched_events
- Rescue hosts that do not have hostname command installed.

## 1.1

- Added send_event_as_json parameter to sent real json
- Added usejson parameter to have the option to sent raw data with time included
- Removed required from parameter definition

## 1.0.1

Fixed config parameters used in Splunk URI.

## 1.0.0

Added all Splunk HTTP Event Collector field options.

## 0.9.1

Replaced RestClient for net/http.

## 0.9.0

First version
