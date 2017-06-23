require 'fluent/output'
require 'net/http'
require 'json'

module Fluent
  class SplunkHECOutput < BufferedOutput
    Fluent::Plugin.register_output('splunkhec', self)

    # Primary Splunk HEC configuration parameters
    config_param :host,     :string, :default => 'localhost'
    config_param :protocol, :string, :default => 'http'
    config_param :port,     :string, :default => '8088'
    config_param :token,    :string, :default => nil

    # Splunk event parameters
    config_param :index,      :string, :default => "main"
    config_param :event_host, :string, :default => nil
    config_param :source,     :string, :default => "fluentd"
    config_param :sourcetype, :string, :default => nil

    # This method is called before starting.
    # Here we construct the Splunk HEC URL to POST data to
    # If the configuration is invalid, raise Fluent::ConfigError.
    def configure(conf)
      super

      @splunk_url = @protocol + '://' + @host + ':' + @port + '/services/collector/event'
      log.debug 'splunkhec: sent data to ' + @splunk_url
      if conf['token'] != nil
        @token = conf['token']
      else
        raise 'splunkhec: token is empty, please provide a token for this plugin to work'
      end

      if conf['event_host'] == nil
        @event_host = `hostname`
        @event_host = @event_host.delete!("\n")
      else
        @event_host = conf['event_host']
      end

      if conf['sourcetype'] == nil
        @event_sourcetype = 'tag'
      else
        @event_sourcetype = conf['sourcetype']
      end
      
      @event_index = @index
      @event_source = @source
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

          if @event_sourcetype == 'tag'
            @event_sourcetype = tag
          end

          # Build body for the POST request
          body = '{"time" :' + time.to_s + ', "event" :"' + event + '", "sourcetype" :"' + @event_sourcetype + '", "source" :"' + @event_source + '", "index" :"' + @event_index + '", "host" : "' + @event_host + '"}'
          log.debug "splunkhec: " + body + "\n"
          
          uri = URI(@splunk_url)
          
          # Create client
          http = Net::HTTP.new(uri.host, uri.port)
          
          # Create Request
          req =  Net::HTTP::Post.new(uri)
          # Add headers
          req.add_field "Authorization", "Splunk #{@token}"
          # Add headers
          req.add_field "Content-Type", "application/json; charset=utf-8"
          # Set body
          req.body = body
          # Handle SSL
          if @protocol == 'https'
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end

          # Fetch Request
          res = http.request(req)
          log.debug "splunkhec: response HTTP Status Code is #{res.code}"
          if res.code.to_i != 200
            log.debug "splunkhec: response body is #{res.body}"
          end
        }
      rescue => err
        log.fatal("splunkhec: caught exception; exiting")
        log.fatal(err)
      end
    end
  end
end
