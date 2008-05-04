require File.dirname(__FILE__) + '/test_helper'

class RowByDefaultTest < Test::Unit::TestCase
  def setup
    @row = PluginAWeek::TableHelper::Row.new
  end
  
  def test_should_not_set_any_html_options
    assert_nil @row[:class]
  end
  
  def test_should_not_have_any_cells
    assert_equal [], @row.cell_names
  end
end


class RowTest < Test::Unit::TestCase
  def setup
    @row = PluginAWeek::TableHelper::Row.new
  end
  
  def test_should_create_reader_after_building_cell
    @row.cell :name
    assert @row.respond_to?(:name)
    assert_instance_of PluginAWeek::TableHelper::Cell, @row.name
  end
  
  def test_should_use_cell_name_for_class_name
    @row.cell :name
    assert_equal 'name', @row.name[:class]
  end
  
  def test_should_sanitize_cell_name_for_reader_method
    @row.cell 'the-name'
    
    assert @row.respond_to?(:the_name)
    assert_instance_of PluginAWeek::TableHelper::Cell, @row.the_name
  end
  
  def test_should_use_unsanitized_cell_name_for_cell_class
    @row.cell 'the-name'
    assert_equal ['the-name'], @row.cell_names
    assert_equal 'the-name', @row.the_name[:class]
  end
  
  def test_should_allow_html_options_when_building_cell
    @row.cell :name, 'Name', :class => 'pretty'
    
    assert_equal 'name pretty', @row.name[:class]
  end
end

class RowWithoutCellsTest < Test::Unit::TestCase
  def setup
    @row = PluginAWeek::TableHelper::Row.new
  end
  
  def test_should_be_able_to_clear_cells
    @row.clear
    assert_equal [], @row.cell_names
  end
  
  def test_should_build_html
    assert_equal '<tr></tr>', @row.html
  end
end

class RowWithCellsTest < Test::Unit::TestCase
  def setup
    @row = PluginAWeek::TableHelper::Row.new
    @row.cell :name
  end
  
  def test_should_have_cell_names
    assert_equal ['name'], @row.cell_names
  end
  
  def test_should_be_able_to_clear_existing_cells
    @row.clear
    
    assert_equal [], @row.cell_names
  end
  
  def test_should_build_html
    assert_equal '<tr><td class="name">Name</td></tr>', @row.html
  end
  
  def test_should_create_new_cell_if_cell_already_exists
    old_cell = @row.name
    
    @row.cell :name
    assert_not_same old_cell, @row.name
  end
  
  def test_should_be_able_to_read_cell_after_clearing
    @row.clear
    @row.cell :name
    
    assert_equal ['name'], @row.cell_names
    assert @row.respond_to?(:name)
  end
end

class RowWithMultipleCellsTest < Test::Unit::TestCase
  def setup
    @row = PluginAWeek::TableHelper::Row.new
    @row.cell :name
    @row.cell :location
  end
  
  def test_should_build_html
    assert_equal '<tr><td class="name">Name</td><td class="location">Location</td></tr>', @row.html
  end
end
