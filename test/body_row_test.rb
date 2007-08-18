require File.dirname(__FILE__) + '/test_helper'

class BodyRowTest < Test::Unit::TestCase
  class Post
    def title
      'Default Value'
    end
  end
  
  BodyRow = PluginAWeek::Helpers::TableHelper::BodyRow
  Header = PluginAWeek::Helpers::TableHelper::Header
  
  def setup
    @post = Post.new
  end
  
  def test_should_not_have_border_type_by_default
    r = BodyRow.new(@post, header)
    assert_nil nil, r.border_type
  end
  
  def test_should_not_alternate_by_default
    r = BodyRow.new(@post, header)
    assert !r.alternate
  end
  
  def test_should_set_default_html_class
    r = BodyRow.new(@post, header)
    assert_equal 'row', r[:class]
  end
  
  def test_should_generate_cell_accessors_created_on_initialization
    r = BodyRow.new(@post, header('title'))
    assert r.respond_to?(:title)
  end
  
  def test_should_add_alternate_class_if_alternating
    r = BodyRow.new(@post, header)
    r.alternate = true
    assert_equal '<tr class="row alternate"></tr>', r.html
  end
  
  def test_should_generate_border_before_cell_if_border_type_is_before
    r = BodyRow.new(@post, header)
    r.border_type = :before
    assert_equal '<tr class="border"><td><div><!-- --></div></td></tr><tr class="row"></tr>', r.html
  end
  
  def test_should_generate_border_after_cell_if_border_type_is_after
    r = BodyRow.new(@post, header)
    r.border_type = :after
    assert_equal '<tr class="row"></tr><tr class="border"><td><div><!-- --></div></td></tr>', r.html
  end
  
  def test_should_raise_exception_if_border_type_is_invalid
    r = BodyRow.new(@post, header)
    assert_raise(ArgumentError) {r.border_type = :invalid}
  end
  
  def test_border_should_not_have_colspan_if_same_number_of_columns_as_cell
    r = BodyRow.new(@post, header('title'))
    r.border_type = :before
    r.title 'Hello World'
    
    assert_equal '<tr class="border"><td><div><!-- --></div></td></tr><tr class="row"><td class="title">Hello World</td></tr>', r.html
  end
  
  def test_border_should_specify_colspan_if_different_number_of_columns_than_cell
    r = BodyRow.new(@post, header('title', 'author_name'))
    r.border_type = :before
    r.title 'Hello World'
    r.author_name 'John Doe'
    
    assert_equal '<tr class="border"><td colspan="2"><div><!-- --></div></td></tr><tr class="row"><td class="title">Hello World</td><td class="author_name">John Doe</td></tr>', r.html
  end
  
  def test_should_use_attribute_values_as_cell_content_by_default
    r = BodyRow.new(@post, header('title', 'author_name'))
    r.author_name 'John Doe'
    
    assert_equal '<tr class="row"><td class="title">Default Value</td><td class="author_name">John Doe</td></tr>', r.html
  end
  
  def test_should_override_default_cell_content_if_cell_specified
    r = BodyRow.new(@post, header('title'))
    r.title 'Hello World'
    
    assert_equal '<tr class="row"><td class="title">Hello World</td></tr>', r.html
  end
  
  def test_should_not_build_cells_if_no_columns
    r = BodyRow.new(@post, header)
    assert_equal '<tr class="row"></tr>', r.html
  end
  
  def test_should_build_missing_cell_if_cell_not_specified
    r = BodyRow.new(@post, header('author_name'))
    assert_equal '<tr class="row"><td class="author_name empty"></td></tr>', r.html
  end
  
  def test_should_build_multiple_missing_cells_if_cells_not_specified
    r = BodyRow.new(@post, header('category', 'author_name'))
    assert_equal '<tr class="row"><td class="category empty"></td><td class="author_name empty"></td></tr>', r.html
  end
  
  def test_should_skip_missing_cells_if_colspan_replaces_missing_cells
    r = BodyRow.new(@post, header('title', 'author_name'))
    r.title 'Hello World', :colspan => 2
    
    assert_equal '<tr class="row"><td class="title" colspan="2">Hello World</td></tr>', r.html
  end
  
  def test_should_not_skip_missing_cells_if_colspan_doesnt_replace_missing_cells
    r = BodyRow.new(@post, header('title', 'author_name'))
    r.title 'Hello World'
    
    assert_equal '<tr class="row"><td class="title">Hello World</td><td class="author_name empty"></td></tr>',r.html
  end
  
  private
  def header(*columns)
    header = Header.new([])
    columns.each {|column| header.column(column)}
    header
  end
end
