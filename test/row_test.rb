require File.dirname(__FILE__) + '/test_helper'

class PluginAWeek::Helpers::TableHelper::Row
  attr_reader :options,
              :html_options
  
  public :build_border
end

class RowTest < Test::Unit::TestCase
  Row = PluginAWeek::Helpers::TableHelper::Row
  
  def setup
    @row = Row.new
  end
  
  def initialize_with_invalid_option
    assert_raise(ArgumentError) {Row.new(:invalid => true)}
  end
  
  def initialize_with_default_options
    r = Row.new
    
    expected_options = {:alternate => false}
    assert_equal expected_options, r.options
    
    expected_html_options = {}
    assert_equal expected_html_options, r.html_options
    
    expected_cells = ActiveSupport::OrderedHash.new
    assert_equal expected_cells, r.cells
  end
  
  def initialize_with_options
    r = Row.new(:alternate => true, :border => :before)
    
    expected_options = {:alternate => true, :border => :before}, r.options
    assert_equal expected_options, r.options
    
    expected_html_options = {}
    assert_equal expected_html_options, r.html_options
    
    expected_cells = ActiveSupport::OrderedHash.new
    assert_equal expected_cells, r.cells
  end
  
  def test_initialize_with_html_options
    r = Row.new({}, {:float => 'left'})
    
    expected_options = {:alternate => false}
    assert_equal expected_options, r.options
    
    expected_html_options = {:float => 'left'}
    assert_equal expected_html_options, r.html_options
    
    expected_cells = ActiveSupport::OrderedHash.new
    assert_equal expected_cells, r.cells
  end
  
  def test_get_html_option
    @row.html_options[:float] = 'left'
    assert_equal 'left', @row[:float]
  end
  
  def test_set_html_option
    @row[:float] = 'left'
    assert_equal 'left', @row[:float]
  end
  
  def test_build_cell_with_default_content
    @row.cell :name
    assert_cell_equal 'td', 'Name', {:class => 'name'}, @row.cells[:name]
  end
  
  def test_build_cell_with_custom_content
    @row.cell :name, 'John Doe'
    assert_cell_equal 'td', 'John Doe', {:class => 'name'}, @row.cells[:name]
  end
  
  def test_build_cell_with_custom_options
    @row.cell :name, 'John Doe', :float => 'left'
    assert_cell_equal 'td', 'John Doe', {:class => 'name', :float => 'left'}, @row.cells[:name]
  end
  
  def test_build_header_with_default_content
    @row.header :name
    assert_cell_equal 'th', 'Name', {:class => 'name'}, @row.cells[:name]
  end
  
  def test_build_header_with_custom_content
    @row.header :name, 'John Doe'
    assert_cell_equal 'th', 'John Doe', {:class => 'name'}, @row.cells[:name]
  end
  
  def test_build_header_with_custom_options
    @row.header :name, 'John Doe', :float => 'left'
    assert_cell_equal 'th', 'John Doe', {:class => 'name', :float => 'left'}, @row.cells[:name]
  end
  
  def test_build_no_cells_with_no_columns
    assert_equal '<tr class="row"></tr>', @row.build
  end
  
  def test_build_no_cells_with_columns
    assert_equal '<tr class="row"></tr>', @row.build([])
  end
  
  def test_build_missing_cell
    assert_equal '<tr class="row"><td class="name empty"></td></tr>', @row.build([:name])
  end
  
  def test_build_multiple_missing_cells
    assert_equal '<tr class="row"><td class="name empty"></td><td class="age empty"></td></tr>', @row.build([:name, :age])
  end
  
  def test_build_with_colspan_and_missing_cell
    @row.cell :name, 'John Doe', :colspan => 2
    assert_equal '<tr class="row"><td class="name" colspan="2">John Doe</td></tr>', @row.build([:name, :age])
  end
  
  def test_build_with_present_and_missing_cells
    @row.cell :name
    assert_equal '<tr class="row"><td class="name">Name</td><td class="age empty"></td></tr>', @row.build([:name, :age])
  end
  
  def test_alternate_row
    r = Row.new(:alternate => true)
    r.cell :name
    assert_equal '<tr class="row alternate"><td class="name">Name</td></tr>', r.build([:name])
  end
  
  def test_border_before
    r = Row.new(:border => :before)
    assert_equal '<tr><td><div class="horizontal_border"><!-- --></div></td></tr><tr class="row"></tr>', r.build
  end
  
  def test_border_after
    r = Row.new(:border => :after)
    assert_equal '<tr class="row"></tr><tr><td><div class="horizontal_border"><!-- --></div></td></tr>', r.build
  end
  
  def test_border_invalid_value
    r = Row.new(:border => :invalid)
    assert_equal '<tr class="row"></tr>', r.build
  end
  
  def test_build_border_no_columns
    assert_equal '<tr><td><div class="horizontal_border"><!-- --></div></td></tr>', @row.build_border
  end
  
  def test_build_border_with_columns
    assert_equal '<tr><td colspan="2"><div class="horizontal_border"><!-- --></div></td></tr>', @row.build_border([:name, :age])
  end
end
