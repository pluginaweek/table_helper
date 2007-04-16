require 'test/unit'
require 'rubygems'
require 'action_controller'
require 'action_view'

root_path = File.dirname(__FILE__) + '/..'
$:.unshift("#{root_path}/../lib")
$:.unshift("#{root_path}/../../ruby/hash/set_or_append/lib")

require 'table_helper'

class Test::Unit::TestCase #:nodoc:
  private
  def assert_html_equal(expected, actual)
    assert_equal expected.gsub(/\n\s*/, ''), actual
  end
end