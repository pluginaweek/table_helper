require File.dirname(__FILE__) + '/test_helper'

class HtmlElementTest < Test::Unit::TestCase
  class DivElement < PluginAWeek::Helpers::TableHelper::HtmlElement
    def tag_name
      'div'
    end
  end
  
  def test_should_set_html_options_on_initialization
    e = PluginAWeek::Helpers::TableHelper::HtmlElement.new(:class => 'fancy')
    assert_equal 'fancy', e[:class]
  end
  
  def test_should_symbolize_html_options
    e = PluginAWeek::Helpers::TableHelper::HtmlElement.new('class' => 'fancy')
    assert_equal 'fancy', e[:class]
  end
  
  def test_should_generate_empty_brackets_if_no_content_and_not_tag_name
    assert_equal '<></>', PluginAWeek::Helpers::TableHelper::HtmlElement.new.html
  end
  
  def test_should_generate_empty_tags_if_no_content
    e = DivElement.new
    assert_equal '<div></div>', e.html
  end
  
  def test_should_generate_entire_element_if_content_and_tag_name_specified
    e = DivElement.new
    e.instance_eval do
      def content
        'hello world'
      end
    end
    
    assert_equal '<div>hello world</div>', e.html
  end
  
  def test_should_include_html_options_in_element_tag
    e = DivElement.new
    e[:class] = 'fancy'
    
    assert_equal '<div class="fancy"></div>', e.html
  end
  
  def test_html_options_should_be_nil_if_never_specified
    e = PluginAWeek::Helpers::TableHelper::HtmlElement.new
    assert_nil e[:class]
  end
  
  def test_should_save_changes_in_html_options
    e = PluginAWeek::Helpers::TableHelper::HtmlElement.new
    e[:float] = 'left'
    assert_equal 'left', e[:float]
  end
end
