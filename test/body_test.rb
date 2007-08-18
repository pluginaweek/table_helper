require File.dirname(__FILE__) + '/test_helper'

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
    @header = PluginAWeek::Helpers::TableHelper::Header.new(@collection)
    @body = PluginAWeek::Helpers::TableHelper::Body.new(@collection, @header)
  end
  
  def test_should_not_alternate_rows_by_default
    assert_nil @body.alternate_rows
  end
  
  def test_should_have_default_empty_caption
    assert_equal 'No matches found.', @body.empty_caption
  end
  
  def test_should_not_have_row_borders_by_default
    assert_nil @body.row_borders
  end
  
  def test_should_raise_exception_if_invalid_alternate_rows_specified
    assert_raise(ArgumentError) {@body.alternate_rows = :invalid}
  end
  
  def test_should_not_raise_exception_for_odd_alternate_rows
    assert_nothing_raised {@body.alternate_rows = :odd}
    assert_equal :odd, @body.alternate_rows
  end
  
  def test_should_not_raise_exception_for_event_alternate_rows
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
      
      expected = <<-end_eval
        <tr class="row">
          <td class="title">#{post.title}</td>
        </tr>
      end_eval
      assert_html_equal expected, html
    end
  end
  
  def test_should_build_row_using_custom_value_for_index
    @header.column :title
    
    html = @body.build_row(@collection.first, 1) do |row, post, index|
      assert_equal @collection.first, post
      assert_equal 1, index
    end
    
    expected = <<-end_eval
      <tr class="row">
        <td class="title">first</td>
      </tr>
    end_eval
    assert_html_equal expected, html
  end
  
  def test_should_alternate_even_row_if_alternate_rows_is_even
    @body.alternate_rows = :even
    @header.column :title
    
    expected = <<-end_eval
      <tr class="row alternate">
        <td class="title">first</td>
      </tr>
    end_eval
    assert_html_equal expected, @body.build_row(@collection.first)
  end
  
  def test_should_not_alternate_odd_row_if_alternate_rows_is_even
    @body.alternate_rows = :even
    @header.column :title
    
    expected = <<-end_eval
      <tr class="row">
        <td class="title">second</td>
      </tr>
    end_eval
    assert_html_equal expected, @body.build_row(@collection[1])
  end
  
  def test_should_alternate_odd_row_if_alternate_rows_is_odd
    @body.alternate_rows = :odd
    @header.column :title
    
    expected = <<-end_eval
      <tr class="row alternate">
        <td class="title">second</td>
      </tr>
    end_eval
    assert_html_equal expected, @body.build_row(@collection[1])
  end
  
  def test_should_not_alternate_even_row_if_alternate_rows_is_odd
    @body.alternate_rows = :odd
    @header.column :title
    
    expected = <<-end_eval
      <tr class="row">
        <td class="title">first</td>
      </tr>
    end_eval
    assert_html_equal expected, @body.build_row(@collection.first)
  end
  
  def test_should_build_border_after_row_if_row_borders_is_after_and_row_is_not_last
    @body.row_borders = :after
    @header.column :title
    
    expected = <<-end_eval
      <tr class="row">
        <td class="title">first</td>
      </tr>
      <tr class="border"><td><div><!-- --></div></td></tr>
    end_eval
    assert_html_equal expected, @body.build_row(@collection.first)
  end
  
  def test_should_not_build_border_after_row_if_row_borders_is_after_and_row_is_last
    @body.row_borders = :after
    @header.column :title
    
    expected = <<-end_eval
      <tr class="row">
        <td class="title">last</td>
      </tr>
    end_eval
    assert_html_equal expected, @body.build_row(@collection.last)
  end
  
  def test_should_build_border_before_row_if_row_borders_is_before_and_row_is_not_first
    @body.row_borders = :before
    @header.column :title
    
    expected = <<-end_eval
      <tr class="border"><td><div><!-- --></div></td></tr>
      <tr class="row">
        <td class="title">last</td>
      </tr>
    end_eval
    assert_html_equal expected, @body.build_row(@collection.last)
  end
  
  def test_should_not_build_border_before_row_if_row_borders_is_before_and_row_is_first
    @body.row_borders = :before
    @header.column :title
    
    expected = <<-end_eval
      <tr class="row">
        <td class="title">first</td>
      </tr>
    end_eval
    assert_html_equal expected, @body.build_row(@collection.first)
  end
  
  def test_should_build_row_with_missing_cells
    @header.column :title
    @header.column :author_name
    
    expected = <<-end_eval
      <tr class="row">
        <td class="title">first</td>
        <td class="author_name empty"></td>
      </tr>
    end_eval
    assert_html_equal expected, @body.build_row(@collection.first)
  end
  
  def test_should_show_no_content_if_collection_is_empty
    @collection.clear
    
    expected = <<-end_eval
      <tr class="no_content">
        <td>No matches found.</td>
      </tr>
    end_eval
    assert_html_equal expected, @body.build
  end
  
  def test_should_be_empty_if_collection_is_empty_and_no_empty_caption
    @collection.clear
    
    @body.empty_caption = nil
    assert_html_equal '', @body.build
  end
  
  def test_should_set_colspan_if_collection_is_empty_and_header_has_multiple_columns
    @collection.clear
    @header.column :title
    @header.column :author_name
    
    expected = <<-end_eval
      <tr class="no_content">
        <td colspan="2">No matches found.</td>
      </tr>
    end_eval
    assert_html_equal expected, @body.build
  end
  
  def test_should_build_all_rows_if_collection_is_not_empty
    @header.column :title
    
    expected = <<-end_eval
      <tr class="row">
        <td class="title">first</td>
      </tr>
      <tr class="row">
        <td class="title">second</td>
      </tr>
      <tr class="row">
        <td class="title">last</td>
      </tr>
    end_eval
    assert_html_equal expected, @body.build
  end
  
  def test_should_build_rows_with_borders_if_collection_is_not_empty
    @body.alternate_rows = :even
    @body.row_borders = :after
    
    @header.column :title
    
    expected = <<-end_eval
      <tr class="row alternate">
        <td class="title">first</td>
      </tr>
      <tr class="border"><td><div><!-- --></div></td></tr>
      <tr class="row">
        <td class="title">second</td>
      </tr>
      <tr class="border"><td><div><!-- --></div></td></tr>
      <tr class="row alternate">
        <td class="title">last</td>
      </tr>
    end_eval
    assert_html_equal expected, @body.build
  end
  
  def test_html_should_use_body_tag
    @header.column :title
    @body.build
    
    expected = <<-end_eval
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
    end_eval
    assert_html_equal expected, @body.html
  end
  
  def test_should_include_custom_attributes_in_body_tag
    @header.column :title
    @body[:class] = 'pretty'
    @body.build
    
    expected = <<-end_eval
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
    end_eval
    assert_html_equal expected, @body.html
  end
end
