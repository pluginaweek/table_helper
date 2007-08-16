require File.dirname(__FILE__) + '/test_helper'

class CellTest < Test::Unit::TestCase
  Cell = PluginAWeek::Helpers::TableHelper::Cell
  
  def test_defaults
    c = Cell.new(:name)
    assert_equal '<td class="name">Name</td>', c.html
  end
  
  def test_custom_content
    c = Cell.new(:name, 'John Doe')
    assert_equal '<td class="name">John Doe</td>', c.html
  end
  
  def test_initialize_with_html_options
    c = Cell.new(:name, 'John Doe', {:float => 'left'})
    assert_equal '<td class="name" float="left">John Doe</td>', c.html
  end
  
  def test_html_options_with_class_already_defined
    c = Cell.new(:name, 'John Doe', {:class => 'selected'})
    assert_equal 'name selected', c[:class]
    assert_equal '<td class="name selected">John Doe</td>', c.html
  end
  
  def test_content_type_invalid
    assert_raise(ArgumentError) { Cell.new(:name).content_type = :invalid }
  end
  
  def test_content_type_data
    c = Cell.new(:name)
    c.content_type = :data
    assert_equal '<td class="name">Name</td>', c.html
  end
  
  def test_content_type_header
    c = Cell.new(:name)
    c.content_type = :header
    assert_equal '<th class="name">Name</th>', c.html
  end
end
