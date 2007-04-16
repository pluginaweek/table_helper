require File.dirname(__FILE__) + '/test_helper'

class BorderTest < Test::Unit::TestCase
  Border = PluginAWeek::Helpers::TableHelper::Border
  Header = PluginAWeek::Helpers::TableHelper::Header
  
  def setup
    @border = Border.new(Header.new([]))
  end
  
  def test_default_values
    assert_equal 'border', @border[:class]
  end
  
  def test_cell
    assert_equal '<td><div><!-- --></div></td>', @border.cell.html
    
    @border.cell[:float] = 'left'
    assert_equal '<td float="left"><div><!-- --></div></td>', @border.cell.html
  end
  
  def test_html
    assert_equal '<tr class="border"><td><div><!-- --></div></td></tr>', @border.html
  end
  
  def test_html_with_custom_options
    @border[:style] = 'display: none;'
    assert_equal '<tr class="border" style="display: none;"><td><div><!-- --></div></td></tr>', @border.html
  end
  
  def test_html_with_multiple_columns
    header = Header.new([])
    header.column :title
    header.column :author_name
    border = Border.new(header)
    assert_equal '<tr class="border"><td colspan="2"><div><!-- --></div></td></tr>', border.html
  end
end
