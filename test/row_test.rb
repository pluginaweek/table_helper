require File.dirname(__FILE__) + '/test_helper'

class RowTest < Test::Unit::TestCase
  def setup
    @row = PluginAWeek::Helpers::TableHelper::Row.new
  end
  
  def test_should_not_set_default_html_class
    assert_nil @row[:class]
  end
  
  def test_should_have_no_cells_by_default
    assert_equal [], @row.cell_names
  end
  
  def test_should_create_reader_after_building_cell
    assert !@row.respond_to?(:name)
    @row.cell :name
    
    assert @row.respond_to?(:name)
    assert_instance_of PluginAWeek::Helpers::TableHelper::Cell, @row.name
  end
  
  def test_should_use_cell_name_for_class_name
    @row.cell :name
    assert_equal 'name', @row.name[:class]
  end
  
  def test_should_sanitize_cell_name_for_reader_method
    assert !@row.respond_to?(:the_name)
    @row.cell 'the-name'
    
    assert @row.respond_to?(:the_name)
    assert_instance_of PluginAWeek::Helpers::TableHelper::Cell, @row.the_name
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
  
  def test_should_create_new_cell_if_cell_already_exists
    @row.cell :name
    old_cell = @row.name
    
    @row.cell :name
    assert_not_same old_cell, @row.name
  end
  
  def test_should_have_cell_names_if_cells_have_been_built
    @row.cell :name
    assert_equal ['name'], @row.cell_names
  end
  
  def test_should_clear_if_no_cells_have_been_built
    @row.clear
    assert_equal [], @row.cell_names
  end
  
  def test_should_clear_if_cells_have_been_built
    @row.cell :name
    @row.clear
    
    assert_equal [], @row.cell_names
  end
  
  def test_should_be_able_to_readd_cell_after_clearing
    @row.cell :name
    @row.clear
    @row.cell :name
    
    assert_equal ['name'], @row.cell_names
    assert @row.respond_to?(:name)
  end
  
  def test_should_only_build_tags_if_no_cells_built
    assert_equal '<tr></tr>', @row.html
  end
  
  def test_should_build_single_cell
    @row.cell :name
    assert_equal '<tr><td class="name">Name</td></tr>', @row.html
  end
  
  def test_should_build_multiple_cells
    @row.cell :name
    @row.cell :location
    assert_equal '<tr><td class="name">Name</td><td class="location">Location</td></tr>', @row.html
  end
end
