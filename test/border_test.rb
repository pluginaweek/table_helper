require File.dirname(__FILE__) + '/test_helper'

class PluginAWeek::Helpers::TableHelper::Border
  attr_reader :row_options,
              :cell_options
end

class BorderTest < Test::Unit::TestCase
  Border = PluginAWeek::Helpers::TableHelper::Border
  
  def setup
    @border = Border.new
  end
  
  def test_default_values
    expected_row_options = {}
    assert_equal expected_row_options, @border.row_options
    
    expected_cell_options = {}
    assert_equal expected_cell_options, @border.cell_options
  end
  
  def test_get_html_option
    @border.row_options[:class] = 'name'
    assert_equal 'name', @border[:class]
  end
  
  def test_set_html_option
    @border[:float] = 'left'
    assert_equal 'left', @border[:float]
    
    expected_row_options = {:float => 'left'}
    assert_equal expected_row_options, @border.row_options
  end
  
  def test_cell
    @border.cell[:float] = 'left'
    assert_equal 'left', @border.cell[:float]
    
    expected_cell_options = {:float => 'left'}
    assert_equal expected_cell_options, @border.cell_options
  end
  
  def test_build_with_defaults
    assert_equal '<tr><td><div class="horizontal_border"><!-- --></div></td></tr>', @border.build
  end
  
  def test_build_with_custom_options
    @border[:class] = 'border'
    @border.cell[:class] = 'green'
    
    assert_equal '<tr class="border"><td class="green"><div class="horizontal_border"><!-- --></div></td></tr>', @border.build
  end
end
