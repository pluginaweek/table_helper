require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class HeaderByDefaultTest < Test::Unit::TestCase
  def setup
    @header = TableHelper::Header.new([])
  end
  
  def test_should_hide_when_empty
    assert @header.hide_when_empty
  end
  
  def test_should_have_no_columns
    assert_equal [], @header.column_names
  end
end

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
  
  def test_should_use_class_columns_if_class_has_column_names
    header = TableHelper::Header.new([], Post)
    assert_equal ['title', 'author_name'], header.column_names
  end
  
  def test_should_have_no_column_names_if_class_has_no_column_names
    header = TableHelper::Header.new([], Array)
    assert_equal [], header.column_names
  end
  
  def test_should_use_class_columns_if_collection_has_objects
    header = TableHelper::Header.new([Post.new])
    assert_equal ['title', 'author_name'], header.column_names
  end
  
  def test_should_use_class_columns_if_collection_is_proxy
    header = TableHelper::Header.new(PostCollection.new)
    assert_equal ['title', 'author_name'], header.column_names
  end
  
  def test_should_create_column_readers_if_column_names_found
    header = TableHelper::Header.new([], Post)
    
    assert_nothing_raised {header.builder.title}
    assert_instance_of TableHelper::Cell, header.builder.title
    
    assert_nothing_raised {header.builder.title}
    assert_instance_of TableHelper::Cell, header.builder.author_name
  end
  
  def test_should_create_column_reader_when_column_is_created
    header = TableHelper::Header.new([])
    header.column :title
    
    assert_equal ['title'], header.column_names
    assert_instance_of TableHelper::Cell, header.builder.title
  end
  
  def test_should_set_column_scope
    header = TableHelper::Header.new([])
    header.column :title
    assert_equal 'col', header.columns['title'][:scope]
  end
  
  def test_should_allow_html_options_to_be_specified_for_new_columns
    header = TableHelper::Header.new([])
    header.column :title, 'Title', :class => 'pretty'
    assert_equal 'title pretty', header.columns['title'][:class]
  end
  
  def test_should_use_column_name_for_default_content
    header = TableHelper::Header.new([])
    header.column :title
    assert_equal '<th class="title" scope="col">Title</th>', header.columns['title'].html
  end
  
  def test_should_sanitize_column_names
    header = TableHelper::Header.new([])
    header.column 'the-title'
    
    assert_nothing_raised {header.builder.the_title}
    assert_instance_of TableHelper::Cell, header.builder.the_title
  end
  
  def test_should_clear_existing_columns_when_first_column_is_created
    header = TableHelper::Header.new([], Post)
    assert_equal ['title', 'author_name'], header.column_names
    
    header.column :created_on
    
    assert_raise(NoMethodError) {header.builder.title}
    assert_raise(NoMethodError) {header.builder.author_name}
    assert_equal ['created_on'], header.column_names
  end
  
  def test_should_include_html_options
    header = TableHelper::Header.new([Post.new])
    header[:class] = 'pretty'
    
    expected = <<-end_str
      <thead class="pretty">
        <tr>
          <th class="title" scope="col">Title</th>
          <th class="author_name" scope="col">Author Name</th>
        </tr>
      </thead>
    end_str
    assert_html_equal expected, header.html
  end
  
  def test_should_include_html_options_for_header_row
    header = TableHelper::Header.new([Post.new])
    header.row[:class] = 'pretty'
    
    expected = <<-end_str
      <thead>
        <tr class="pretty">
          <th class="title" scope="col">Title</th>
          <th class="author_name" scope="col">Author Name</th>
        </tr>
      </thead>
    end_str
    assert_html_equal expected, header.html
  end
end

class HeaderWithConflictingColumnNamesTest < Test::Unit::TestCase
  def setup
    @header = TableHelper::Header.new([])
    @header.column 'id'
  end
  
  def test_should_be_able_to_read_cell
    assert_instance_of TableHelper::Cell, @header.builder.id
  end
  
  def test_should_be_able_to_write_to_cell
    @header.builder.id '1'
    assert_instance_of TableHelper::Cell, @header.builder.id
  end
  
  def test_should_be_able_to_clear
    assert_nothing_raised {@header.clear}
  end
end

class HeaderWithEmptyCollectionTest < Test::Unit::TestCase
  def setup
    @header = TableHelper::Header.new([])
  end
  
  def test_should_not_display_if_hide_when_empty
    @header.hide_when_empty = true
    
    expected = <<-end_str
      <thead style="display: none;">
        <tr>
        </tr>
      </thead>
    end_str
    assert_html_equal expected, @header.html
  end
  
  def test_should_display_if_not_hide_when_empty
    @header.hide_when_empty = false
    
    expected = <<-end_str
      <thead>
        <tr>
        </tr>
      </thead>
    end_str
    assert_html_equal expected, @header.html
  end
end

class HeaderWithCollectionTest < Test::Unit::TestCase
  class Post
    def self.column_names
      ['title', 'author_name']
    end
  end
  
  def setup
    @header = TableHelper::Header.new([Post.new])
  end
  
  def test_should_display_if_hide_when_empty
    @header.hide_when_empty = true
    
    expected = <<-end_str
      <thead>
        <tr>
          <th class="title" scope="col">Title</th>
          <th class="author_name" scope="col">Author Name</th>
        </tr>
      </thead>
    end_str
    assert_html_equal expected, @header.html
  end
  
  def test_should_display_if_not_hide_when_empty
    @header.hide_when_empty = false
    
    expected = <<-end_str
      <thead>
        <tr>
          <th class="title" scope="col">Title</th>
          <th class="author_name" scope="col">Author Name</th>
        </tr>
      </thead>
    end_str
    assert_html_equal expected, @header.html
  end
end
