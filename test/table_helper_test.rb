require File.dirname(__FILE__) + '/test_helper'

class TableHelperTest < Test::Unit::TestCase
  include PluginAWeek::Helpers::TableHelper
  
  def test_collection_table
    table = collection_table([])
    assert_not_nil table
    assert_instance_of PluginAWeek::Helpers::TableHelper::CollectionTable, table
  end
  
  def test_collection_table_yields
    table = collection_table([]) do |yielded_table|
      assert_not_nil yielded_table
      assert_instance_of PluginAWeek::Helpers::TableHelper::CollectionTable, yielded_table
    end
  end
end
