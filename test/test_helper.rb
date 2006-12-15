require 'test/unit'
require 'rubygems'
require 'action_controller'
require 'action_view'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require File.dirname(__FILE__) + '/../init'

class Test::Unit::TestCase #:nodoc:
  private
  def assert_cell_equal(tag_name, content, html_options, cell)
    assert_equal tag_name, cell.tag_name
    assert_equal content, cell.content
    assert_equal html_options, cell.html_options
  end
end