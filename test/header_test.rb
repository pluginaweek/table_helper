require File.dirname(__FILE__) + '/test_helper'

class HeaderTest < Test::Unit::TestCase
  class Post
    def self.column_names
      ['title', 'author_name']
    end
  end
  
  class Reflection
    def klass
      Post
    end
  end
  
  class PostCollection < Array
    def proxy_reflection
      Reflection.new
    end
  end
  
  Header = PluginAWeek::Helpers::TableHelper::Header
  
  def test_should_hide_when_empty_by_default
    header = Header.new([])
  end
  
  def test_should_have_no_columns_by_default_if_collection_is_empty_and_no_class_specified
    header = Header.new([])
    assert_equal [], header.column_names
  end
  
  def test_should_use_class_columns_if_class_has_column_names
    header = Header.new([], Post)
    assert_equal ['title', 'author_name'], header.column_names
  end
  
  def test_should_have_no_column_names_if_class_has_no_column_names
    header = Header.new([], Array)
    assert_equal [], header.column_names
  end
  
  def test_should_use_class_columns_if_collection_has_objects
    header = Header.new([Post.new])
    assert_equal ['title', 'author_name'], header.column_names
  end
  
  def test_should_use_class_columns_if_collection_is_proxy
    header = Header.new(PostCollection.new)
    assert_equal ['title', 'author_name'], header.column_names
  end
  
  def test_should_create_column_readers_if_column_names_found_on_initialization
    header = Header.new([], Post)
    
    assert header.respond_to?(:title)
    assert_instance_of PluginAWeek::Helpers::TableHelper::Cell, header.title
    
    assert header.respond_to?(:author_name)
    assert_instance_of PluginAWeek::Helpers::TableHelper::Cell, header.author_name
  end
  
  def test_should_create_column_reader_when_column_is_created
    header = Header.new([])
    header.column :title
    
    assert_equal ['title'], header.column_names
    assert_instance_of PluginAWeek::Helpers::TableHelper::Cell, header.title
  end
  
  def test_should_set_column_scope
    header = Header.new([])
    header.column :title
    assert_equal 'col', header.title[:scope]
  end
  
  def test_should_allow_html_options_to_be_specified_for_new_columns
    header = Header.new([])
    header.column :title, 'Title', :class => 'pretty'
    assert_equal 'title pretty', header.title[:class]
  end
  
  def test_should_use_column_name_for_default_content
    header = Header.new([])
    header.column :title
    assert_equal '<th class="title" scope="col">Title</th>', header.title.html
  end
  
  def test_should_sanitize_column_names
    header = Header.new([])
    header.column 'the-title'
    
    assert header.respond_to?(:the_title)
    assert_instance_of PluginAWeek::Helpers::TableHelper::Cell, header.the_title
  end
  
  def test_should_clear_existing_columns_when_first_column_is_created
    header = Header.new([], Post)
    assert_equal ['title', 'author_name'], header.column_names
    
    header.column :created_on
    
    assert !header.respond_to?(:title)
    assert !header.respond_to?(:author_name)
    assert_equal ['created_on'], header.column_names
  end
  
  def test_should_hide_header_if_empty_header_and_empty_collection
    header = Header.new([])
    
    expected = <<-end_eval
      <thead style="display: none;">
        <tr>
        </tr>
      </thead>
    end_eval
    assert_html_equal expected, header.html
  end
  
  def test_should_not_hide_header_if_empty_header_empty_collection_and_no_hide_when_empty
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
  
  def test_should_build_html_for_empty_header_and_non_empty_collection
    header = Header.new([Post.new])
    
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
  
  def test_should_built_html_for_empty_header_non_empty_collection_and_no_hide_when_empty
    header = Header.new([Post.new])
    header.hide_when_empty = false
    
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
  
  def test_should_include_html_options_for_header
    header = Header.new([Post.new])
    header[:class] = 'pretty'
    
    expected = <<-end_eval
      <thead class="pretty">
        <tr>
          <th class="title" scope="col">Title</th>
          <th class="author_name" scope="col">Author Name</th>
        </tr>
      </thead>
    end_eval
    assert_html_equal expected, header.html
  end
  
  def test_should_include_html_options_for_header_row
    header = Header.new([Post.new])
    header.row[:class] = 'pretty'
    
    expected = <<-end_eval
      <thead>
        <tr class="pretty">
          <th class="title" scope="col">Title</th>
          <th class="author_name" scope="col">Author Name</th>
        </tr>
      </thead>
    end_eval
    assert_html_equal expected, header.html
  end
end
