require File.dirname(__FILE__) + '/test_helper'

class FooterTest < Test::Unit::TestCase
  def test_should_hide_when_empty_by_default
    footer = PluginAWeek::Helpers::TableHelper::Footer.new([])
    assert footer.hide_when_empty
  end
  
  def test_should_not_display_if_hide_when_empty_and_collection_is_empty
    footer = PluginAWeek::Helpers::TableHelper::Footer.new([])
    footer.hide_when_empty = true
    
    expected = <<-end_eval
      <tfoot style="display: none;">
        <tr>
        </tr>
      </tfoot>
    end_eval
    assert_html_equal expected, footer.html
  end
  
  def test_should_display_if_not_hiding_when_empty_and_collection_is_empty
    footer = PluginAWeek::Helpers::TableHelper::Footer.new([])
    footer.hide_when_empty = false
    
    expected = <<-end_eval
      <tfoot>
        <tr>
        </tr>
      </tfoot>
    end_eval
    assert_html_equal expected, footer.html
  end
  
  def test_should_include_custom_attributes_for_footer_tag
    footer = PluginAWeek::Helpers::TableHelper::Footer.new([1])
    footer[:class] = 'pretty'
    
    expected = <<-end_eval
      <tfoot class="pretty">
        <tr>
        </tr>
      </tfoot>
    end_eval
    assert_html_equal expected, footer.html
  end
  
  def test_should_include_created_cells_when_built
    footer = PluginAWeek::Helpers::TableHelper::Footer.new([1])
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
