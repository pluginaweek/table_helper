require File.dirname(__FILE__) + '/test_helper'

class CellTest < Test::Unit::TestCase
  Cell = PluginAWeek::Helpers::TableHelper::Cell
  
  def test_should_set_default_class_name_on_initialization
    c = Cell.new(:name)
    assert_equal 'name', c[:class]
  end
  
  def test_default_content_should_be_humanized_class_name
    c = Cell.new(:name)
    assert_equal '<td class="name">Name</td>', c.html
  end
  
  def test_should_use_custom_content_if_specified
    c = Cell.new(:name, 'John Doe')
    assert_equal '<td class="name">John Doe</td>', c.html
  end
  
  def test_should_include_custom_html_options
    c = Cell.new(:name, 'John Doe', {:float => 'left'})
    assert_equal '<td class="name" float="left">John Doe</td>', c.html
  end
  
  def test_should_append_automated_class_name_if_class_already_specified
    c = Cell.new(:name, 'John Doe', {:class => 'selected'})
    assert_equal 'name selected', c[:class]
    assert_equal '<td class="name selected">John Doe</td>', c.html
  end
  
  def test_should_raise_exception_if_content_type_is_invalid
    assert_raise(ArgumentError) { Cell.new(:name).content_type = :invalid }
  end
  
  def test_default_content_type_should_be_data
    c = Cell.new(:name)
    assert_equal '<td class="name">Name</td>', c.html
  end
  
  def test_should_create_data_cell_if_content_type_is_data
    c = Cell.new(:name)
    c.content_type = :data
    assert_equal '<td class="name">Name</td>', c.html
  end
  
  def test_should_create_header_cell_if_content_type_is_header
    c = Cell.new(:name)
    c.content_type = :header
    assert_equal '<th class="name">Name</th>', c.html
  end
end
