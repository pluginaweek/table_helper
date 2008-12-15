require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class BodyByDefaultTest < Test::Unit::TestCase
  def setup
    header = TableHelper::Header.new([])
    @body = TableHelper::Body.new([], header)
  end
  
  def test_should_not_alternate_rows
    assert_nil @body.alternate_rows
  end
  
  def test_should_have_an_empty_caption
    assert_equal 'No matches found.', @body.empty_caption
  end
end

class BodyTest < Test::Unit::TestCase
  class Post
    attr_accessor :title
    
    def initialize(title)
      @title = title
    end
  end
  
  def setup
    @collection = [
      Post.new('first'),
      Post.new('second'),
      Post.new('last')
    ]
    @header = TableHelper::Header.new(@collection)
    @body = TableHelper::Body.new(@collection, @header)
  end
  
  def test_should_raise_exception_if_invalid_alternate_rows_specified
    assert_raise(ArgumentError) {@body.alternate_rows = :invalid}
  end
  
  def test_should_not_raise_exception_for_odd_alternate_rows
    assert_nothing_raised {@body.alternate_rows = :odd}
    assert_equal :odd, @body.alternate_rows
  end
  
  def test_should_not_raise_exception_for_even_alternate_rows
    assert_nothing_raised {@body.alternate_rows = :even}
    assert_equal :even, @body.alternate_rows
  end
  
  def test_should_build_row_using_object_location_for_default_index
    @header.column :title
    
    @collection.each do |post|
      html = @body.build_row(post) do |row, built_post, index|
        assert_equal post, built_post
        assert_equal @collection.index(post), index
      end
      
      expected = <<-end_str
        <tr class="row">
          <td class="title">#{post.title}</td>
        </tr>
      end_str
      assert_html_equal expected, html
    end
  end
  
  def test_should_build_row_using_custom_value_for_index
    @header.column :title
    
    html = @body.build_row(@collection.first, 1) do |row, post, index|
      assert_equal @collection.first, post
      assert_equal 1, index
    end
    
    expected = <<-end_str
      <tr class="row">
        <td class="title">first</td>
      </tr>
    end_str
    assert_html_equal expected, html
  end
  
  def test_should_build_row_with_missing_cells
    @header.column :title
    @header.column :author_name
    
    expected = <<-end_str
      <tr class="row">
        <td class="title">first</td>
        <td class="author_name empty"></td>
      </tr>
    end_str
    assert_html_equal expected, @body.build_row(@collection.first)
  end
  
  def test_should_build_all_rows
    @header.column :title
    
    expected = <<-end_str
      <tr class="row">
        <td class="title">first</td>
      </tr>
      <tr class="row">
        <td class="title">second</td>
      </tr>
      <tr class="row">
        <td class="title">last</td>
      </tr>
    end_str
    assert_html_equal expected, @body.build
  end
  
  def test_html_should_use_body_tag
    @header.column :title
    @body.build
    
    expected = <<-end_str
      <tbody>
        <tr class="row">
          <td class="title">first</td>
        </tr>
        <tr class="row">
          <td class="title">second</td>
        </tr>
        <tr class="row">
          <td class="title">last</td>
        </tr>
      </tbody>
    end_str
    assert_html_equal expected, @body.html
  end
  
  def test_should_include_custom_attributes_in_body_tag
    @header.column :title
    @body[:class] = 'pretty'
    @body.build
    
    expected = <<-end_str
      <tbody class="pretty">
        <tr class="row">
          <td class="title">first</td>
        </tr>
        <tr class="row">
          <td class="title">second</td>
        </tr>
        <tr class="row">
          <td class="title">last</td>
        </tr>
      </tbody>
    end_str
    assert_html_equal expected, @body.html
  end
end

class BodyWithEmptyCollectionTest < Test::Unit::TestCase
  def setup
    @collection = []
    @header = TableHelper::Header.new(@collection)
    @body = TableHelper::Body.new(@collection, @header)
  end
  
  def test_should_show_no_content
    expected = <<-end_str
      <tr class="no_content">
        <td>No matches found.</td>
      </tr>
    end_str
    assert_html_equal expected, @body.build
  end
  
  def test_should_be_empty_if_no_empty_caption
    @body.empty_caption = nil
    assert_html_equal '', @body.build
  end
  
  def test_should_set_colspan_if_header_has_multiple_columns
    @header.column :title
    @header.column :author_name
    
    expected = <<-end_str
      <tr class="no_content">
        <td colspan="2">No matches found.</td>
      </tr>
    end_str
    assert_html_equal expected, @body.build
  end
end

class BodyWithAlternatingEvenRowsTest < Test::Unit::TestCase
  class Post
    attr_accessor :title
    
    def initialize(title)
      @title = title
    end
  end
  
  def setup
    @collection = [
      Post.new('first'),
      Post.new('second'),
      Post.new('last')
    ]
    @header = TableHelper::Header.new(@collection)
    @header.column :title
    
    @body = TableHelper::Body.new(@collection, @header)
    @body.alternate_rows = :even
  end
  
  def test_should_alternate_even_row
    expected = <<-end_str
      <tr class="row alternate">
        <td class="title">first</td>
      </tr>
    end_str
    assert_html_equal expected, @body.build_row(@collection.first)
  end
  
  def test_should_not_alternate_odd_row
    expected = <<-end_str
      <tr class="row">
        <td class="title">second</td>
      </tr>
    end_str
    assert_html_equal expected, @body.build_row(@collection[1])
  end
end

class BodyWithAlternatingOddRowsTest < Test::Unit::TestCase
  class Post
    attr_accessor :title
    
    def initialize(title)
      @title = title
    end
  end
  
  def setup
    @collection = [
      Post.new('first'),
      Post.new('second'),
      Post.new('last')
    ]
    @header = TableHelper::Header.new(@collection)
    @header.column :title
    
    @body = TableHelper::Body.new(@collection, @header)
    @body.alternate_rows = :odd
  end
  
  def test_should_alternate_odd_row
    expected = <<-end_str
      <tr class="row alternate">
        <td class="title">second</td>
      </tr>
    end_str
    assert_html_equal expected, @body.build_row(@collection[1])
  end
  
  def test_should_not_alternate_even_row
    expected = <<-end_str
      <tr class="row">
        <td class="title">first</td>
      </tr>
    end_str
    assert_html_equal expected, @body.build_row(@collection.first)
  end
end
