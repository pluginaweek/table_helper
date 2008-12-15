require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class RowByDefaultTest < Test::Unit::TestCase
  def setup
    @row = TableHelper::Row.new
  end
  
  def test_should_not_set_any_html_options
    assert_nil @row[:class]
  end
  
  def test_should_not_have_any_cells
    assert @row.cells.empty?
  end
  
  def test_should_not_have_any_cell_names
    assert_equal [], @row.cell_names
  end
  
  def test_should_have_a_builder
    assert_not_nil @row.builder
  end
end

class RowTest < Test::Unit::TestCase
  def setup
    @row = TableHelper::Row.new
  end
  
  def test_should_create_cell_reader_after_building_cell
    @row.cell :name
    assert_nothing_raised {@row.builder.name}
    assert_instance_of TableHelper::Cell, @row.builder.name
  end
  
  def test_should_use_cell_name_for_class_name
    @row.cell :name
    assert_equal 'name', @row.cells['name'][:class]
  end
  
  def test_should_sanitize_cell_name_for_reader_method
    @row.cell 'the-name'
    
    @row.builder.the_name
    assert_nothing_raised {@row.builder.the_name}
    assert_instance_of TableHelper::Cell, @row.builder.the_name
  end
  
  def test_should_use_unsanitized_cell_name_for_cell_class
    @row.cell 'the-name'
    assert_equal ['the-name'], @row.cell_names
    assert_equal 'the-name', @row.cells['the-name'][:class]
  end
  
  def test_should_allow_html_options_when_building_cell
    @row.cell :name, 'Name', :class => 'pretty'
    
    assert_equal 'name pretty', @row.cells['name'][:class]
  end
end

class RowWithoutCellsTest < Test::Unit::TestCase
  def setup
    @row = TableHelper::Row.new
  end
  
  def test_should_be_able_to_clear_cells
    @row.clear
    assert_equal [], @row.cell_names
  end
  
  def test_should_build_html
    assert_equal '<tr></tr>', @row.html
  end
end

class RowWithCellsTest < Test::Unit::TestCase
  def setup
    @row = TableHelper::Row.new
    @row.cell :name
  end
  
  def test_should_have_cell_names
    assert_equal ['name'], @row.cell_names
  end
  
  def test_should_be_able_to_clear_existing_cells
    @row.clear
    
    assert_equal [], @row.cell_names
  end
  
  def test_should_build_html
    assert_equal '<tr><td class="name">Name</td></tr>', @row.html
  end
  
  def test_should_create_new_cell_if_cell_already_exists
    old_cell = @row.cells['name']
    
    @row.cell :name
    assert_not_same old_cell, @row.cells['name']
  end
  
  def test_should_be_able_to_read_cell_after_clearing
    @row.clear
    @row.cell :name
    
    assert_equal ['name'], @row.cell_names
    assert_nothing_raised {@row.builder.name}
  end
end

class RowWithMultipleCellsTest < Test::Unit::TestCase
  def setup
    @row = TableHelper::Row.new
    @row.cell :name
    @row.cell :location
  end
  
  def test_should_build_html
    assert_equal '<tr><td class="name">Name</td><td class="location">Location</td></tr>', @row.html
  end
end

class RowWithConflictingCellNamesTest < Test::Unit::TestCase
  def setup
    @row = TableHelper::Row.new
    @row.cell :id
  end
  
  def test_should_be_able_to_read_cell
    assert_instance_of TableHelper::Cell, @row.cells['id']
  end
  
  def test_should_be_able_to_write_to_cell
    @row.builder.id '1'
    assert_instance_of TableHelper::Cell, @row.cells['id']
  end
  
  def test_should_be_able_to_clear
    assert_nothing_raised {@row.clear}
  end
end
