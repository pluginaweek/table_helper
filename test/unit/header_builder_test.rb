require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class HeaderBuilderByDefaultTest < Test::Unit::TestCase
  def setup
    @header = TableHelper::Header.new([])
    @builder = TableHelper::HeaderBuilder.new(@header)
  end
  
  def test_should_forward_missing_calls_to_row
    assert_equal '<thead style="display: none;"><tr></tr></thead>', @builder.html
  end
end

class HeaderBuilderWithColumnsTest < Test::Unit::TestCase
  def setup
    @header = TableHelper::Header.new([])
    @header.row.cell 'first-name'
    
    @builder = TableHelper::HeaderBuilder.new(@header)
    @builder.define_column('first-name')
  end
  
  def test_should_create_column_reader
    assert_nothing_raised {@builder.first_name}
  end
  
  def test_should_read_column_without_arguments
    assert_instance_of TableHelper::Cell, @builder.first_name
  end
  
  def test_should_write_cell_with_arguments
    @builder.first_name 'Your Name'
    assert_equal '<td class="first-name">Your Name</td>', @header.row.cells['first-name'].html
  end
end

class RowBuilderAfterUndefiningAColumnTest < Test::Unit::TestCase
  def setup
    @header = TableHelper::Header.new([])
    @builder = TableHelper::HeaderBuilder.new(@header)
    @builder.define_column('first-name')
    @builder.undef_column('first-name')
  end
  
  def test_should_not_have_cell_reader
    assert_raise(NoMethodError) {@builder.first_name}
  end
end
