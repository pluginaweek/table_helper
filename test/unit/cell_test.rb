require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class CellByDefaultTest < Test::Unit::TestCase
  def setup
    @cell = TableHelper::Cell.new(:name)
  end
  
  def test_should_have_a_class_name
    assert_equal 'name', @cell[:class]
  end
  
  def test_should_use_humanized_class_name_for_content
    assert_equal '<td class="name">Name</td>', @cell.html
  end
  
  def test_should_create_a_data_cell
    assert_equal '<td class="name">Name</td>', @cell.html
  end
end

class CellTest < Test::Unit::TestCase
  def test_should_use_custom_content_if_specified
    cell = TableHelper::Cell.new(:name, 'John Doe')
    assert_equal '<td class="name">John Doe</td>', cell.html
  end
  
  def test_should_include_custom_html_options
    cell = TableHelper::Cell.new(:name, 'John Doe', {:float => 'left'})
    assert_equal '<td class="name" float="left">John Doe</td>', cell.html
  end
  
  def test_should_append_automated_class_name_if_class_already_specified
    cell = TableHelper::Cell.new(:name, 'John Doe', {:class => 'selected'})
    assert_equal 'name selected', cell[:class]
    assert_equal '<td class="name selected">John Doe</td>', cell.html
  end
  
  def test_should_raise_exception_if_content_type_is_invalid
    assert_raise(ArgumentError) {TableHelper::Cell.new(:name).content_type = :invalid}
  end
end

class CellWithHeaderContentType < Test::Unit::TestCase
  def setup
    @cell = TableHelper::Cell.new(:name)
    @cell.content_type = :header
  end
  
  def test_should_a_header_cell
    assert_equal '<th class="name">Name</th>', @cell.html
  end
end
