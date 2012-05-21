# Load the plugin testing framework
$:.unshift("#{File.dirname(__FILE__)}/../lib")
require 'rails'
require 'active_support'
require 'active_record'
require 'action_view'
require 'action_controller'
require 'table_helper'
require 'test/unit'
Test::Unit::TestCase.class_eval do
  private
    def assert_html_equal(expected, actual)
      assert_equal expected.strip.gsub(/\n\s*/, ''), actual
    end
end
