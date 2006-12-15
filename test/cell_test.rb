require File.dirname(__FILE__) + '/test_helper'

class PluginAWeek::Helpers::TableHelper::Cell
  attr_reader :tag_name,
              :content,
              :html_options
end

class CellTest < Test::Unit::TestCase
  Cell = PluginAWeek::Helpers::TableHelper::Cell
  
  def test_initialize_with_defaults
    c = Cell.new('td', :name)
    assert_cell_equal 'td', 'Name', {:class => 'name'}, c
  end
  
  def test_initialize_with_custom_content
    c = Cell.new('td', :name, 'John Doe')
    assert_cell_equal 'td', 'John Doe', {:class => 'name'}, c
  end
  
  def test_initialize_with_html_options
    c = Cell.new('td', :name, 'John Doe', {:float => 'left'})
    assert_cell_equal 'td', 'John Doe', {:class => 'name', :float => 'left'}, c
  end
  
  def test_initialize_with_class_already_defined
    c = Cell.new('td', :name, 'John Doe', {:class => 'selected'})
    assert_cell_equal 'td', 'John Doe', {:class => 'name selected'}, c
  end
  
  def test_empty_data_cell
    empty_data = Cell.empty_data
    assert_cell_equal 'td', '', {:class => 'empty'}, empty_data
  end
  
  def test_empty_header_cell
    empty_header = Cell.empty_header
    assert_cell_equal 'th', '', {:class => 'empty'}, empty_header
  end
  
  def test_empty_data_cell_with_class_name
    empty_data = Cell.empty_data(:name)
    assert_cell_equal 'td', '', {:class => 'name empty'}, empty_data
  end
  
  def test_empty_header_cell_with_class_name
    empty_header = Cell.empty_header(:name)
    assert_cell_equal 'th', '', {:class => 'name empty'}, empty_header
  end
  
  def test_get_html_option
    c = Cell.new('td', :name)
    assert_equal 'name', c[:class]
  end
  
  def test_set_html_option
    c = Cell.new('td', :name)
    c[:float] = 'left'
    assert_equal 'left', c[:float]
  end
  
  def test_build
    c = Cell.new('td', :name)
    assert_equal '<td class="name">Name</td>', c.build
  end
end
