require File.dirname(__FILE__) + '/test_helper'

class HtmlElementTest < Test::Unit::TestCase
  class DivElement < PluginAWeek::Helpers::TableHelper::HtmlElement
    def tag_name
      'div'
    end
  end
  
  HtmlElement = PluginAWeek::Helpers::TableHelper::HtmlElement
  
  def test_html_options_on_initialization
    e = HtmlElement.new('class' => 'fancy')
    assert_equal 'fancy', e[:class]
    
    e = HtmlElement.new(:class => 'fancy')
    assert_equal 'fancy', e[:class]
  end
  
  def test_html_no_content
    assert_equal '<></>', HtmlElement.new.html
  end
  
  def test_html_with_content
    e = DivElement.new
    e.instance_eval do
      def content
        'hello world'
      end
    end
    
    assert_equal '<div>hello world</div>', e.html
  end
  
  def test_html_with_html_options
    e = DivElement.new
    e[:class] = 'fancy'
    
    assert_equal '<div class="fancy"></div>', e.html
  end
  
  def test_get_html_option
    e = HtmlElement.new
    assert_nil e[:class]
  end
  
  def test_set_html_option
    e = HtmlElement.new
    e[:float] = 'left'
    assert_equal 'left', e[:float]
  end
end