require File.dirname(__FILE__) + '/test_helper'

class RowTest < Test::Unit::TestCase
  Row = PluginAWeek::Helpers::TableHelper::Row
  
  def setup
    @row = Row.new
  end
  
  def test_default_html_options
    assert_nil @row[:class]
  end
  
  def test_default_cells
    assert_equal [], @row.cell_names
    assert_equal '<tr></tr>', @row.html
  end
  
  def test_one_cell
    @row.cell :name
    assert_equal ['name'], @row.cell_names
    assert_equal '<tr><td class="name">Name</td></tr>', @row.html
  end
  
  def test_cell_returns_cell
    cell = @row.cell :name
    assert_instance_of PluginAWeek::Helpers::TableHelper::Cell, cell
  end
  
  def test_cell_with_dash
    @row.cell 'the-name'
    assert_equal ['the-name'], @row.cell_names
    assert_equal '<tr><td class="the-name">The Name</td></tr>', @row.html
  end
  
  def test_clear_cells
    @row.cell :name
    @row.clear
    
    assert_equal [], @row.cell_names
    assert !@row.respond_to?(:name)
    assert_equal '<tr></tr>', @row.html
  end
  
  def test_clear_cells_and_readd
    @row.cell :name
    @row.clear
    @row.cell :name
    
    assert_equal ['name'], @row.cell_names
    assert @row.respond_to?(:name)
  end
  
  def test_cell_reader
    @row.cell :name
    
    assert @row.respond_to?(:name)
    assert_not_nil @row.name
    assert_equal '<td class="name">Name</td>', @row.name.html
  end
  
  def test_cell_reader_with_dash
    @row.cell 'the-name'
    
    assert @row.respond_to?(:the_name)
    assert_not_nil @row.the_name
    assert_equal '<td class="the-name">The Name</td>', @row.the_name.html
  end
  
  def test_cell_writer
    @row.cell :name
    
    assert @row.respond_to?(:name)
    @row.name 'Company Name'
    
    assert_equal '<tr><td class="name">Company Name</td></tr>', @row.html
  end
  
  def test_cell_with_html_options
    @row.cell :name, 'Name', :class => 'pretty'
    @row.name.content_type = :header
    
    assert_equal '<tr><th class="name pretty">Name</th></tr>', @row.html
  end
end
