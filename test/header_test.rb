require File.dirname(__FILE__) + '/test_helper'

class HeaderTest < Test::Unit::TestCase
  class Post
    def self.column_names
      ['title', 'author_name']
    end
  end
  
  Header = PluginAWeek::Helpers::TableHelper::Header
  
  def test_defaults
    header = Header.new([])
    assert header.hide_when_empty
    assert_equal [], header.column_names
  end
  
  def test_defaults_with_class
    header = Header.new([], Post)
    assert header.hide_when_empty
    assert_equal ['title', 'author_name'], header.column_names
  end
  
  def test_accessor_methods
    header = Header.new([], Post)
    
    assert header.respond_to?(:title)
    assert_instance_of PluginAWeek::Helpers::TableHelper::Cell, header.title
    
    assert header.respond_to?(:author_name)
    assert_instance_of PluginAWeek::Helpers::TableHelper::Cell, header.author_name
  end
  
  def test_accessor_methods_with_dash
    header = Header.new([])
    header.column 'the-title'
    
    assert header.respond_to?(:the_title)
    assert_instance_of PluginAWeek::Helpers::TableHelper::Cell, header.the_title
  end
  
  def test_create_new_column
    header = Header.new([])
    header.column :title
    
    assert_equal ['title'], header.column_names
    assert_instance_of PluginAWeek::Helpers::TableHelper::Cell, header.title
  end
  
  def test_existing_columns_cleared_on_new_column
    header = Header.new([], Post)
    assert_equal ['title', 'author_name'], header.column_names
    
    header.column :created_on
    
    assert !header.respond_to?(:title)
    assert !header.respond_to?(:author_name)
    assert_equal ['created_on'], header.column_names
  end
  
  def test_empty_header_and_empty_collection
    header = Header.new([])
    
    expected = <<-end_eval
<thead style="display: none;">
  <tr>
  </tr>
</thead>
end_eval
    assert_html_equal expected, header.html
  end
  
  def test_empty_header_and_empty_collection_no_hide_when_empty
    header = Header.new([])
    header.hide_when_empty = false
    
    expected = <<-end_eval
<thead>
  <tr>
  </tr>
</thead>
end_eval
    assert_html_equal expected, header.html
  end
  
  def test_empty_header_and_non_empty_collection
    header = Header.new([Post.new])
    
    expected = <<-end_eval
<thead>
  <tr>
  </tr>
</thead>
end_eval
    assert_html_equal expected, header.html
  end
  
  def test_empty_header_and_non_empty_collection_no_hide_when_empty
    header = Header.new([Post.new])
    header.hide_when_empty = false
    
    expected = <<-end_eval
<thead>
  <tr>
  </tr>
</thead>
end_eval
    assert_html_equal expected, header.html
  end
  
  def test_html_with_known_class
    header = Header.new([Post.new], Post)
    
    expected = <<-end_eval
<thead>
  <tr>
    <th class="title" scope="col">Title</th>
    <th class="author_name" scope="col">Author Name</th>
  </tr>
</thead>
end_eval
    assert_html_equal expected, header.html
  end
  
  def test_html_with_html_options
    header = Header.new([Post.new])
    header[:class] = 'pretty'
    
    expected = <<-end_eval
<thead class="pretty">
  <tr>
  </tr>
</thead>
end_eval
    assert_html_equal expected, header.html
  end
end