require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class BodyRowByDefaultTest < Test::Unit::TestCase
  def setup
    header = TableHelper::Header.new([])
    @row = TableHelper::BodyRow.new(Object.new, header)
  end
  
  def test_should_not_alternate
    assert !@row.alternate
  end
  
  def test_should_have_a_class_name
    assert_equal 'row', @row[:class]
  end
end

class BodyRowTest < Test::Unit::TestCase
  class Post
    def title
      'Default Value'
    end
  end
  
  def setup
    header = TableHelper::Header.new([])
    header.column :title
    @row = TableHelper::BodyRow.new(Post.new, header)
  end
  
  def test_should_generate_cell_accessors
    assert_nothing_raised {@row.builder.title}
  end
  
  def test_should_override_default_cell_content_if_cell_specified
    @row.builder.title 'Hello World'
    assert_equal '<tr class="row"><td class="title">Hello World</td></tr>', @row.html
  end
end

class BodyRowWithNoColumnsTest < Test::Unit::TestCase
  def setup
    header = TableHelper::Header.new([])
    @row = TableHelper::BodyRow.new(Object.new, header)
  end
  
  def test_should_not_build_cells
    assert_equal '<tr class="row"></tr>', @row.html
  end
end

class BodyRowWithCustomAttributeTest < Test::Unit::TestCase
  class Post
    def title
      'Default Value'
    end
  end
  
  def setup
    header = TableHelper::Header.new([])
    header.column :title
    header.column :author_name
    @row = TableHelper::BodyRow.new(Post.new, header)
  end
  
  def test_should_use_attribute_values_as_cell_content
    @row.builder.author_name 'John Doe'
    assert_equal '<tr class="row"><td class="title">Default Value</td><td class="author_name">John Doe</td></tr>', @row.html
  end
end

class BodyRowWithMissingCellsTest < Test::Unit::TestCase
  def setup
    header = TableHelper::Header.new([])
    header.column :title
    header.column :author_name
    @row = TableHelper::BodyRow.new(Object.new, header)
  end
  
  def test_should_build_missing_cells_if_cells_not_specified
    assert_equal '<tr class="row"><td class="title empty"></td><td class="author_name empty"></td></tr>', @row.html
  end
  
  def test_should_skip_missing_cells_if_colspan_replaces_missing_cells
    @row.builder.title 'Hello World', :colspan => 2
    assert_equal '<tr class="row"><td class="title" colspan="2">Hello World</td></tr>', @row.html
  end
  
  def test_should_not_skip_missing_cells_if_colspan_doesnt_replace_missing_cells
    @row.builder.title 'Hello World'
    assert_equal '<tr class="row"><td class="title">Hello World</td><td class="author_name empty"></td></tr>', @row.html
  end
end

class BodyRowAlternatingTest < Test::Unit::TestCase
  def setup
    header = TableHelper::Header.new([])
    @row = TableHelper::BodyRow.new(Object.new, header)
    @row.alternate = true
  end
  
  def test_should_add_alternate_class
    assert_equal '<tr class="row alternate"></tr>', @row.html
  end
end
