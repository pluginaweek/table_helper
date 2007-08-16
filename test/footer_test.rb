require File.dirname(__FILE__) + '/test_helper'

class FooterTest < Test::Unit::TestCase
  Footer = PluginAWeek::Helpers::TableHelper::Footer
  
  def test_defaults
    footer = Footer.new([])
    assert footer.hide_when_empty
  end
  
  def test_html_empty_collection
    footer = Footer.new([])
    
    expected = <<-end_eval
<tfoot style="display: none;">
  <tr>
  </tr>
</tfoot>
end_eval
    assert_html_equal expected, footer.html
  end
  
  def test_html_empty_collection_no_hide_when_empty
    footer = Footer.new([])
    footer.hide_when_empty = false
    
    expected = <<-end_eval
<tfoot>
  <tr>
  </tr>
</tfoot>
end_eval
    assert_html_equal expected, footer.html
  end
  
  def test_html_custom_attributes
    footer = Footer.new([1])
    footer[:class] = 'pretty'
    
    expected = <<-end_eval
<tfoot class="pretty">
  <tr>
  </tr>
</tfoot>
end_eval
    assert_html_equal expected, footer.html
  end
  
  def test_create_cell
    footer = Footer.new([1])
    footer.cell :total, 20
    
    expected = <<-end_eval
<tfoot>
  <tr>
    <td class="total">20</td>
  </tr>
</tfoot>
end_eval
    assert_html_equal expected, footer.html
  end
end