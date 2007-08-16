require File.dirname(__FILE__) + '/test_helper'

class BodyTest < Test::Unit::TestCase
  class Post
    attr_accessor :title
    
    def initialize(title)
      @title = title
    end
  end
  
  Body = PluginAWeek::Helpers::TableHelper::Body
  Header = PluginAWeek::Helpers::TableHelper::Header
  
  def setup
    @collection = [
      Post.new('first'),
      Post.new('second'),
      Post.new('last')
    ]
    @header = Header.new(@collection)
    @body = Body.new(@collection, @header)
  end
  
  def test_default_values
    assert_nil @body.alternate_rows
    assert_equal 'No matches found.', @body.empty_caption
    assert_nil @body.row_borders
  end
  
  def test_invalid_alternate_rows
    assert_raise(ArgumentError) {@body.alternate_rows = :invalid}
  end
  
  def test_valid_alternate_rows
    assert_nothing_raised {@body.alternate_rows = :odd}
    assert_equal :odd, @body.alternate_rows
    
    assert_nothing_raised {@body.alternate_rows = :even}
    assert_equal :even, @body.alternate_rows
  end
  
  def test_build_row_default_index
    @header.column :title
    
    actual = @body.build_row(@collection.first) do |row, post, index|
      assert_equal @collection.first, post
      assert_equal 0, index
    end
    
    expected = <<-end_eval
<tr class="row">
  <td class="title">first</td>
</tr>
end_eval
    assert_html_equal expected, actual
  end
  
  def test_build_row_custom_index
    @header.column :title
    
    actual = @body.build_row(@collection.first, 1) do |row, post, index|
      assert_equal @collection.first, post
      assert_equal 1, index
    end
    
    expected = <<-end_eval
<tr class="row">
  <td class="title">first</td>
</tr>
end_eval
    assert_html_equal expected, actual
  end
  
  def test_build_row_alternate_even
    @body.alternate_rows = :even
    @header.column :title
    
    expected = <<-end_eval
<tr class="row alternate">
  <td class="title">first</td>
</tr>
end_eval
    assert_html_equal expected, @body.build_row(@collection.first)
  end
  
  def test_build_row_alternate_odd
    @body.alternate_rows = :odd
    @header.column :title
    
    expected = <<-end_eval
<tr class="row alternate">
  <td class="title">second</td>
</tr>
end_eval
    assert_html_equal expected, @body.build_row(@collection[1])
  end
  
  def test_build_row_with_border_after
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
  
  def test_build_last_row_with_no_border_after
    @body.row_borders = :after
    @header.column :title
    
    expected = <<-end_eval
<tr class="row">
  <td class="title">last</td>
</tr>
end_eval
    assert_html_equal expected, @body.build_row(@collection.last)
  end
  
  def test_build_row_with_border_before
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
  
  def test_build_first_row_with_no_border_before
    @body.row_borders = :before
    @header.column :title
    
    expected = <<-end_eval
<tr class="row">
  <td class="title">first</td>
</tr>
end_eval
    assert_html_equal expected, @body.build_row(@collection.first)
  end
  
  def test_build_row_with_missing_cells
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
  
  def test_build_empty_collection
    @collection.clear
    
    expected = <<-end_eval
<tr class="no_content">
  <td>No matches found.</td>
</tr>
end_eval
    assert_html_equal expected, @body.build
  end
  
  def test_build_empty_collection_but_content_on_empty
    @collection.clear
    
    @body.empty_caption = nil
    assert_html_equal '', @body.build
  end
  
  def test_build_empty_collection_multiple_columns
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
  
  def test_build_non_empty_collection
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
  
  def test_build_body_with_alternate_and_borders
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
  
  def test_html
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
  
  def test_html_with_custom_attributes
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