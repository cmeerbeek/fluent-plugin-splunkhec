require 'fluent/output'
require 'rest-client'

module Fluent
  class SplunkHECOutput < BufferedOutput
    Fluent::Plugin.register_output('splunkhec', self)

    config_param :host,     :string, :default => 'localhost', :required => true
    config_param :protocol, :string, :default => 'https'
    config_param :port,     :string, :default => '8088'
    config_param :token,    :string, :default => nil, :required => true

    # This method is called before starting.
    # Here we construct the Splunk HEC URL to POST data to
    # If the configuration is invalid, raise Fluent::ConfigError.
    def configure(conf)
      super 

      @splunk_url = conf['protocol'] + '://' + conf['host'] ':' + conf['port'] + '/services/collector/event'
      log.debug "POSTing data to " + @splunk_url  
      @token = conf['token']  
    end

    def start
      super
    end

    def shutdown
      super
    end

    # This method is called when an event reaches to Fluentd.
    # Convert the event to a raw string.
    def format(tag, time, record)
      [tag, time, record].to_json + "\n"
      ## Alternatively, use msgpack to serialize the object.
      # [tag, time, record].to_msgpack
    end

    # This method is called every flush interval. Write the buffer chunk
    # to files or databases here.
    # 'chunk' is a buffer chunk that includes multiple formatted
    # events. You can use 'data = chunk.read' to get all events and
    # 'chunk.open {|io| ... }' to get IO objects.
    #
    # NOTE! This method is called by internal thread, not Fluentd's main thread. So IO wait doesn't affect other plugins.
    #def write(chunk)
    #  data = chunk.read
    #  print data
    #end

    # Optionally, you can use chunk.msgpack_each to deserialize objects.
    def write(chunk)
      chunk.msgpack_each {|(tag,time,record)|
        begin
          log.debug "Tag: " + tag + " / Time: " + time + " / Record: " + record
          RestClient.post @splunk_url, {:time => time, :event => record, :sourcetype => tag}, {:Authorization => 'Splunk ' + @token}
        rescue => e
          log.fatal "Error occureding during POST: " + e.response
      }
    end
  end
end