require 'fluent/output'
require 'rest-client'
require 'json'

module Fluent
  class SplunkHECOutput < BufferedOutput
    Fluent::Plugin.register_output('splunkhec', self)

    # Primary Splunk configuration parameters
    config_param :host,     :string, :default => 'localhost', :required => true
    config_param :protocol, :string, :default => 'https'
    config_param :port,     :string, :default => '8088'
    config_param :token,    :string, :default => nil, :required => true

    # This method is called before starting.
    # Here we construct the Splunk HEC URL to POST data to
    # If the configuration is invalid, raise Fluent::ConfigError.
    def configure(conf)
      super 

      @splunk_url = conf['protocol'] + '://' + conf['host'] + ':' + conf['port'] + '/services/collector/event'
      log.debug 'splunkhec: sent data to ' + @splunk_url
      if conf['token'] != nil
        @token = conf['token']
      else
        raise 'splunkhec: token is empty, please provide a token for this plugin to work'
      end
    end

    def start
      super
    end

    def shutdown
      super
    end

    # This method is called when an event reaches to Fluentd.
    # Use msgpack to serialize the object.
    def format(tag, time, record)
      [tag, time, record].to_msgpack
    end

    # Loop through all records and sent them to Splunk
    def write(chunk)
      begin
        chunk.msgpack_each {|(tag,time,record)|
          # Parse record to Splunk event format
          case record
          when Fixnum
            event = record.to_s
          when Hash
            event = record.to_json.gsub("\"", %q(\\\"))
          else
            event = record
          end

          # Build body for the POST request
          body = '{"time" :' + time.to_s + ', "event" :"' + event + '", "sourcetype" :"' + tag + '"}'
          log.debug "splunkhec: " + body + "\n"
          
          # Create POST request
          response = RestClient.post(@splunk_url, body, {:Authorization => 'Splunk ' + @token})
          log.debug "\nsplunkhec: response body is " + response.body.to_json + "\n"
        }
      rescue => e
        log.fatal e.response
      end
    end
  end
end