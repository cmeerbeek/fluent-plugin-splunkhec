require 'helper'

class SplunkHECOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  ### for Splunk HEC
  CONFIG_SPLUNKHEC = %[
    host splunk.bluefactory.nl
    protocol https
    port 8443
    token BAB747F3-744E-41BA
  ]

  def create_driver_ga(conf = CONFIG_SPLUNKHEC)
    Fluent::Test::InputTestDriver.new(Fluent::SplunkHECOutput).configure(conf)
  end

  def test_configure_splunkhec
    d = create_driver_splunkhec
    assert_equal 'splunk.bluefactory.nl', d.instance.host
    assert_equal 'https' , d.instance.protocol
    assert_equal '8443' , d.instance.port
    assert_equal 'BAB747F3-744E-41BA', d.instance.token
  end

end
