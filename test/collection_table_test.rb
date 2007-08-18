require File.dirname(__FILE__) + '/test_helper'

class CollectionTableTest < Test::Unit::TestCase
  class Note
    def self.column_names
      ['title', 'author_name']
    end
    
    attr_accessor :title
    
    def initialize(title)
      @title = title
    end
  end
  
  class Post < Note
    def self.column_names
      ['title']
    end
  end
  
  class Reflection
    def klass
      Note
    end
  end
  
  class NoteCollection < Array
    def proxy_reflection
      Reflection.new
    end
  end
  
  CollectionTable = PluginAWeek::Helpers::TableHelper::CollectionTable
  Body = PluginAWeek::Helpers::TableHelper::Body
  Header = PluginAWeek::Helpers::TableHelper::Header
  Footer = PluginAWeek::Helpers::TableHelper::Footer
  
  def setup
    @collection = [
      Post.new('first'),
      Post.new('second'),
      Post.new('last')
    ]
  end
  
  def test_should_raise_exception_if_invalid_option_specified
    assert_raise(ArgumentError) {CollectionTable.new([], :invalid => true)}
  end
  
  def test_default_cellspacing_should_be_zero
    table = CollectionTable.new([])
    assert_equal '0', table[:cellspacing]
  end
  
  def test_default_cellpadding_should_be_zero
    table = CollectionTable.new([])
    assert_equal '0', table[:cellpadding]
  end
  
  def test_should_only_include_body_if_no_header
    table = CollectionTable.new(@collection, :header => false)
    html = table.build do |body|
      assert_instance_of Body, body
    end
    
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
    assert_html_equal expected, html
  end
  
  def test_should_include_header_and_body_by_default
    table = CollectionTable.new(@collection)
    html = table.build do |header, body|
      assert_instance_of Header, header
      assert_instance_of Body, body
    end
    
    expected = <<-end_eval
      <thead>
        <tr>
          <th class="title" scope="col">Title</th>
        </tr>
      </thead>
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
    assert_html_equal expected, html
  end
  
  def test_should_include_body_and_footer_if_no_header_and_footer
    table = CollectionTable.new(@collection, :header => false, :footer => true)
    html = table.build do |body, footer|
      assert_instance_of Body, body
      assert_instance_of Footer, footer
    end
    
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
      <tfoot>
        <tr>
        </tr>
      </tfoot>
    end_eval
    assert_html_equal expected, html
  end
  
  def test_should_include_header_body_and_footer_if_footer
    table = CollectionTable.new(@collection, :footer => true)
    html = table.build do |header, body, footer|
      assert_instance_of Header, header
      assert_instance_of Body, body
      assert_instance_of Footer, footer
    end
    
    expected = <<-end_eval
      <thead>
        <tr>
          <th class="title" scope="col">Title</th>
        </tr>
      </thead>
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
      <tfoot>
        <tr>
        </tr>
      </tfoot>
    end_eval
    assert_html_equal expected, html
  end
  
  def test_should_use_custom_class_to_generate_columns
    table = CollectionTable.new(@collection, :class => Note)
    html = table.build
    
    expected = <<-end_eval
      <thead>
        <tr>
          <th class="title" scope="col">Title</th>
          <th class="author_name" scope="col">Author Name</th>
        </tr>
      </thead>
      <tbody>
        <tr class="row">
          <td class="title">first</td>
          <td class="author_name empty"></td>
        </tr>
        <tr class="row">
          <td class="title">second</td>
          <td class="author_name empty"></td>
        </tr>
        <tr class="row">
          <td class="title">last</td>
          <td class="author_name empty"></td>
        </tr>
      </tbody>
    end_eval
    assert_html_equal expected, html
  end
  
  def test_should_use_class_from_first_element_to_generate_columns
    @collection.insert(0, Note.new('zeroth'))
    table = CollectionTable.new(@collection)
    html = table.build
    
    expected = <<-end_eval
      <thead>
        <tr>
          <th class="title" scope="col">Title</th>
          <th class="author_name" scope="col">Author Name</th>
        </tr>
      </thead>
      <tbody>
        <tr class="row">
          <td class="title">zeroth</td>
          <td class="author_name empty"></td>
        </tr>
        <tr class="row">
          <td class="title">first</td>
          <td class="author_name empty"></td>
        </tr>
        <tr class="row">
          <td class="title">second</td>
          <td class="author_name empty"></td>
        </tr>
        <tr class="row">
          <td class="title">last</td>
          <td class="author_name empty"></td>
        </tr>
      </tbody>
    end_eval
    assert_html_equal expected, html
  end
  
  def test_should_use_class_from_proxy_reflection_to_generate_columns
    collection = NoteCollection.new
    collection.concat(@collection)
    table = CollectionTable.new(collection)
    html = table.build
    
    expected = <<-end_eval
      <thead>
        <tr>
          <th class="title" scope="col">Title</th>
          <th class="author_name" scope="col">Author Name</th>
        </tr>
      </thead>
      <tbody>
        <tr class="row">
          <td class="title">first</td>
          <td class="author_name empty"></td>
        </tr>
        <tr class="row">
          <td class="title">second</td>
          <td class="author_name empty"></td>
        </tr>
        <tr class="row">
          <td class="title">last</td>
          <td class="author_name empty"></td>
        </tr>
      </tbody>
    end_eval
    assert_html_equal expected, html
  end
end
