require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class FooterByDefaultTest < Test::Unit::TestCase
  def setup
    @footer = TableHelper::Footer.new([])
  end
  
  def test_should_hdie_when_empty
    assert @footer.hide_when_empty
  end
end

class FooterTest < Test::Unit::TestCase
  def setup
    @footer = TableHelper::Footer.new([1])
  end
  
  def test_should_include_custom_attributes
    @footer[:class] = 'pretty'
    
    expected = <<-end_str
      <tfoot class="pretty">
        <tr>
        </tr>
      </tfoot>
    end_str
    assert_html_equal expected, @footer.html
  end
  
  def test_should_include_created_cells_when_built
    @footer.cell :total, 20
    
    expected = <<-end_str
      <tfoot>
        <tr>
          <td class="total">20</td>
        </tr>
      </tfoot>
    end_str
    assert_html_equal expected, @footer.html
  end
end

class FooterWithEmptyCollectionTest < Test::Unit::TestCase
  def setup
    @footer = TableHelper::Footer.new([])
  end
 
  def test_should_not_display_if_hide_when_empty
    @footer.hide_when_empty = true
    
    expected = <<-end_str
      <tfoot style="display: none;">
        <tr>
        </tr>
      </tfoot>
    end_str
    assert_html_equal expected, @footer.html
  end
  
  def test_should_display_if_not_hide_when_empty
    @footer.hide_when_empty = false
    
    expected = <<-end_str
      <tfoot>
        <tr>
        </tr>
      </tfoot>
    end_str
    assert_html_equal expected, @footer.html
  end
end
