# fluent-plugin-splunkhec, a plugin for [Fluentd](http://fluentd.org)

## Overview

***Splunk HTTP Event Collector*** input plugin.

Output JSON metrics from any datasource to the Splunk HTTP Event Collector (Splunk HEC).

The Splunk HEC is running on a Heavy Forwarder. More info about the Splunk HEC architecture in a distributed environment can be found in the Splunk [Docs](http://dev.splunk.com/view/event-collector/SP-CAAAE73)

## Configuration

```config
<match splunkhec>
    @type splunkhec
    host splunk.bluefactory.nl
    protocol https
    port 8080
    token BAB747F3-744E-41BA
</source>
```

## config: host

The host where the Splunk HEC is running.

## config: protocol

The protocol on which the Splunk HEC is listening.

## config: port

The port on which the Splunk HEC is listening.

## config: token

Every Splunk HEC requires a token to recieve data. You must configure this insite Splunk [Splunk HEC docs](http://docs.splunk.com/Documentation/Splunk/latest/Data/UsetheHTTPEventCollector).
Put the token here.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
