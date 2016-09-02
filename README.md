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
    protocol https
    port 8080
    token BAB747F3-744E-41BA
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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## TODO

* Add support for weak certificates
* Add support for custom index, source and sourcetype fields 
