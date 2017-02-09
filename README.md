# fluent-plugin-splunkhec, a plugin for [Fluentd](http://fluentd.org)

## Overview

***Splunk HTTP Event Collector*** output plugin.

Output data from any Fluent input plugin to the Splunk HTTP Event Collector (Splunk HEC).

The Splunk HEC is running on a Heavy Forwarder or single instance. More info about the Splunk HEC architecture in a distributed environment can be found in the Splunk [Docs](http://dev.splunk.com/view/event-collector/SP-CAAAE73)

## Configuration

```config
<match splunkhec>
    @type splunkhec
    host splunk.bluefactory.nl
    protocol https #optional
    port 8080 #optional
    token BAB747F3-744E-41BA
    index main #optional
    event_host fluentdhost #optional
    source fluentd #optional
    sourcetype data:type #optional
</source>
```

## config: host

The host where the Splunk HEC is listening (Heavy Forwarder or Single Instance).

## config: protocol

The protocol on which the Splunk HEC is listening. If you are going to use HTTPS make sure you use a signed certificate. Weak certificates are a work in progress.

## config: port

The port on which the Splunk HEC is listening.

## config: token

Every Splunk HEC requires a token to recieve data. You must configure this insite Splunk [Splunk HEC docs](http://docs.splunk.com/Documentation/Splunk/latest/Data/UsetheHTTPEventCollector).
Put the token here.

## config: index

The index on the Splunk side to store the data in. Please be aware that the Splunk HTTP Event Collector you've created has the permissions to write to this index. If you don't specify this the plug-in will use "main".

## config: event_host

Specify the host-field for the event data in Splunk. If you don't specify this the plug-in will try to read the hostname running FluentD.

## config: source

Specify the source-field for the event data in Splunk. If you don't specify this the plug-in will use "fluentd".

## config: sourcetype

Specify the sourcetype-field for the event data in Splunk. If you don't specify this the plug-in will use the tag from the FluentD input plug-in.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## TODO

* Add support for SSL verification.
 
## Copyright

Copyright (c) 2017 Coen Meerbeek. See [LICENSE](LICENSE) for details.
