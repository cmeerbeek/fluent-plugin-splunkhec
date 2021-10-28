require 'fluent/plugin/output'
require 'net/http'
require 'yajl'

module Fluent::Plugin
  class SplunkHECOutput < Output
    Fluent::Plugin.register_output('splunkhec', self)

    helpers :compat_parameters, :event_emitter

    DEFAULT_BUFFER_TYPE = "memory"

    # Primary Splunk HEC configuration parameters
    config_param :host,     :string, :default => 'localhost'
    config_param :protocol, :string, :default => 'http'
    config_param :port,     :string, :default => '8088'
    config_param :token,    :string

    # Splunk event parameters
    config_param :index,               :string, :default => 'main'
    config_param :event_host,          :string, :default => nil
    config_param :source,              :string, :default => 'fluentd'
    config_param :sourcetype,          :string, :default => 'tag'
    config_param :send_event_as_json,  :bool,   :default => false
    config_param :usejson,             :bool,   :default => true
    config_param :send_batched_events, :bool,   :default => false

    config_section :buffer do
      config_set_default :@type, DEFAULT_BUFFER_TYPE
    end

    # This method is called before starting.
    # Here we construct the Splunk HEC URL to POST data to
    # If the configuration is invalid, raise Fluent::ConfigError.
    def configure(conf)
      compat_parameters_convert(conf, :buffer)
      super
      @splunk_url = @protocol + '://' + @host + ':' + @port + '/services/collector/event'
      log.info 'splunkhec: sending data to ' + @splunk_url

      if conf['event_host'] == nil
        begin
          @event_host = `hostname`.delete!("\n")
        rescue
          @event_host = 'unknown'
        end
      end
      @packer = Fluent::MessagePackFactory.engine_factory.packer
    end

    def start
      super
    end

    def shutdown
      super
    end

    def formatted_to_msgpack_binary?
      true
    end

    def multi_workers_ready?
      true
    end

    # This method is called when an event reaches to Fluentd.
    # Use msgpack to serialize the object.
    def format(tag, time, record)
      @packer.pack([tag, time, record]).to_s
    end

    def expand_param(param, tag, time, record)
      # check for '${ ... }'
      #   yes => `eval`
      #   no  => return param
      return param if (param =~ /\${.+}/).nil?

      # check for 'tag_parts[]'
      # separated by a delimiter (default '.')
      tag_parts = tag.split(@delimiter) unless (param =~ /tag_parts\[.+\]/).nil? || tag.nil?

      # pull out section between ${} then eval
      inner = param.clone
      while inner.match(/\${.+}/)
        to_eval = inner.match(/\${(.+?)}/){$1}

        if !(to_eval =~ /record\[.+\]/).nil? && record.nil?
          return to_eval
        elsif !(to_eval =~/tag_parts\[.+\]/).nil? && tag_parts.nil?
          return to_eval
        elsif !(to_eval =~/time/).nil? && time.nil?
          return to_eval
        else
          inner.sub!(/\${.+?}/, eval( to_eval ))
        end
      end
      inner
    end

    # Loop through all records and sent them to Splunk
    def write(chunk)
      body = ''
      chunk.msgpack_each {|(tag,time,record)|

        # define index and sourcetype dynamically
        begin
          index = expand_param(@index, tag, time, record)
          sourcetype = expand_param(@sourcetype, tag, time, record)
          event_host = expand_param(@event_host, tag, time, record)
          token = expand_param(@token, tag, time, record)
        rescue => e
          # handle dynamic parameters misconfigurations
          router.emit_error_event(tag, time, record, e)
          next
        end
        log.debug "routing event from #{event_host} to #{index} index"
        log.debug "expanded token #{token}"

        # Parse record to Splunk event format
        case record
        when Integer
          event = record.to_s
        when Hash
          if @send_event_as_json
            event = Yajl::Encoder.encode(record)
          else
            event = Yajl::Encoder.encode(record).gsub("\"", %q(\\\"))
          end
        else
          event = record
        end

        sourcetype = @sourcetype == 'tag' ? tag : @sourcetype

        # Build body for the POST request
        if !@usejson
          event = record["time"]+ " " + Yajl::Encoder.encode(record["message"]).gsub(/^"|"$/,"")
          body << '{"time":"'+ DateTime.parse(record["time"]).strftime("%Q") +'", "event":"' + event + '", "sourcetype" :"' + sourcetype + '", "source" :"' + @source + '", "index" :"' + index + '", "host" : "' + event_host + '"}'
        elsif @send_event_as_json
          body << '{"time" :' + time.to_s + ', "event" :' + event + ', "sourcetype" :"' + sourcetype + '", "source" :"' + source + '", "index" :"' + index + '", "host" : "' + event_host + '"}'
        else
          body << '{"time" :' + time.to_s + ', "event" :"' + event + '", "sourcetype" :"' + sourcetype + '", "source" :"' + source + '", "index" :"' + index + '", "host" : "' + event_host + '"}'
        end

        if @send_batched_events
          body << "\n"
        else
          send_to_splunk(body, token)
          body = ''
        end
      }

      if @send_batched_events
        send_to_splunk(body, token)
      end
    end

    def send_to_splunk(body, token)
      log.debug "splunkhec: " + body + "\n"

      uri = URI(@splunk_url)

      # Create client
      http = Net::HTTP.new(uri.host, uri.port)
      http.set_debug_output(log.debug)

      # Create request
      req = Net::HTTP::Post.new(uri, "Content-Type" => "application/json; charset=utf-8", "Authorization" => "Splunk #{token}")
      req.body = body

      # Handle SSL
      if @protocol == 'https'
        http.use_ssl = true
      end

      # Send Request
      res = http.request(req)

      log.debug "splunkhec: HTTP Response Status Code is #{res.code}"

      if res.code.to_i != 200
        body = Yajl::Parser.parse(res.body)
        raise SplunkHECOutputError.new(body['text'], body['code'], body['invalid-event-number'], res.code)
      end
    end
  end

  class SplunkHECOutputError < StandardError
    def initialize(message, status_code, invalid_event_number, http_status_code)
      super("#{message} (http status code #{http_status_code}, status code #{status_code}, invalid event number #{invalid_event_number})")
    end
  end

end
