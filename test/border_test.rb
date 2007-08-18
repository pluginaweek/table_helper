require File.dirname(__FILE__) + '/test_helper'

class BorderTest < Test::Unit::TestCase
  def setup
    @border = PluginAWeek::Helpers::TableHelper::Border.new(PluginAWeek::Helpers::TableHelper::Header.new([]))
  end
  
  def test_should_set_default_css_class
    assert_equal 'border', @border[:class]
  end
  
  def test_should_render_empty_cell
    assert_equal '<td><div><!-- --></div></td>', @border.cell.html
  end
  
  def test_should_render_empty_cell_with_additional_html_attributes
    @border.cell[:float] = 'left'
    assert_equal '<td float="left"><div><!-- --></div></td>', @border.cell.html
  end
  
  def test_should_render_row
    assert_equal '<tr class="border"><td><div><!-- --></div></td></tr>', @border.html
  end
  
  def test_should_render_row_with_custom_options
    @border[:style] = 'display: none;'
    assert_equal '<tr class="border" style="display: none;"><td><div><!-- --></div></td></tr>', @border.html
  end
  
  def test_should_include_colspan_if_header_has_multiple_columns
    header = PluginAWeek::Helpers::TableHelper::Header.new([])
    header.column :title
    header.column :author_name
    border = PluginAWeek::Helpers::TableHelper::Border.new(header)
    assert_equal '<tr class="border"><td colspan="2"><div><!-- --></div></td></tr>', border.html
  end
end
