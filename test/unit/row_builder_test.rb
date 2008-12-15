require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class RowBuilderByDefaultTest < Test::Unit::TestCase
  def setup
    @row = TableHelper::Row.new
    @builder = TableHelper::RowBuilder.new(@row)
  end
  
  def test_should_forward_missing_calls_to_row
    assert_equal '<tr></tr>', @builder.html
  end
end

class RowBuilderWithCellsTest < Test::Unit::TestCase
  def setup
    @row = TableHelper::Row.new
    @builder = TableHelper::RowBuilder.new(@row)
    @builder.define_cell('first-name')
  end
  
  def test_should_create_cell_reader
    assert_nothing_raised {@builder.first_name}
  end
  
  def test_should_read_cell_without_arguments
    @row.cells['first-name'] = TableHelper::Cell.new('first-name')
    assert_instance_of TableHelper::Cell, @builder.first_name
  end
  
  def test_should_write_cell_with_arguments
    @builder.first_name 'Your Name'
    assert_equal '<td class="first-name">Your Name</td>', @row.cells['first-name'].html
  end
end

class RowBuilderAfterUndefiningACellTest < Test::Unit::TestCase
  def setup
    @row = TableHelper::Row.new
    @builder = TableHelper::RowBuilder.new(@row)
    @builder.define_cell('first-name')
    @builder.undef_cell('first-name')
  end
  
  def test_should_not_have_cell_reader
    assert_raise(NoMethodError) {@builder.first_name}
  end
end
