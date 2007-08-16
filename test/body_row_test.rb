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
  
  def test_defaults
    r = BodyRow.new(@post, header)
    assert_nil nil, r.border_type
    assert !r.alternate
  end
  
  def test_cell_accessors_created_on_initialization
    r = BodyRow.new(@post, header('title'))
    assert r.respond_to?(:title)
  end
  
  def test_alternate_row
    r = BodyRow.new(@post, header)
    r.alternate = true
    assert_equal '<tr class="row alternate"></tr>', r.html
  end
  
  def test_border_before
    r = BodyRow.new(@post, header)
    r.border_type = :before
    assert_equal '<tr class="border"><td><div><!-- --></div></td></tr><tr class="row"></tr>', r.html
  end
  
  def test_border_after
    r = BodyRow.new(@post, header)
    r.border_type = :after
    assert_equal '<tr class="row"></tr><tr class="border"><td><div><!-- --></div></td></tr>', r.html
  end
  
  def test_invalid_border_type
    r = BodyRow.new(@post, header)
    assert_raise(ArgumentError) {r.border_type = :invalid}
  end
  
  def test_border_one_column
    r = BodyRow.new(@post, header('title'))
    r.border_type = :before
    r.title 'Hello World'
    
    assert_equal '<tr class="border"><td><div><!-- --></div></td></tr><tr class="row"><td class="title">Hello World</td></tr>', r.html
  end
  
  def test_border_multiple_columns
    r = BodyRow.new(@post, header('title', 'author_name'))
    r.border_type = :before
    r.title 'Hello World'
    r.author_name 'John Doe'
    
    assert_equal '<tr class="border"><td colspan="2"><div><!-- --></div></td></tr><tr class="row"><td class="title">Hello World</td><td class="author_name">John Doe</td></tr>', r.html
  end
  
  def test_default_cell_values
    r = BodyRow.new(@post, header('title', 'author_name'))
    r.author_name 'John Doe'
    
    assert_equal '<tr class="row"><td class="title">Default Value</td><td class="author_name">John Doe</td></tr>', r.html
  end
  
  def test_override_default_cell_value
    r = BodyRow.new(@post, header('title'))
    r.title 'Hello World'
    
    assert_equal '<tr class="row"><td class="title">Hello World</td></tr>', r.html
  end
  
  def test_build_no_cells_with_no_columns
    r = BodyRow.new(@post, header)
    assert_equal '<tr class="row"></tr>', r.html
  end
  
  def test_build_missing_cell
    r = BodyRow.new(@post, header('author_name'))
    assert_equal '<tr class="row"><td class="author_name empty"></td></tr>', r.html
  end
  
  def test_build_multiple_missing_cells
    r = BodyRow.new(@post, header('category', 'author_name'))
    assert_equal '<tr class="row"><td class="category empty"></td><td class="author_name empty"></td></tr>', r.html
  end
  
  def test_build_with_colspan_and_missing_cell
    r = BodyRow.new(@post, header('title', 'author_name'))
    r.title 'Hello World', :colspan => 2
    
    assert_equal '<tr class="row"><td class="title" colspan="2">Hello World</td></tr>', r.html
  end
  
  def test_build_with_present_and_missing_cells
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