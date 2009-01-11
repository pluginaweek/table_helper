require 'table_helper/html_element'
require 'table_helper/header'
require 'table_helper/body'
require 'table_helper/footer'

module TableHelper
  # Represents a table that displays data for multiple objects within a
  # collection.
  class CollectionTable < HtmlElement
    # Creates a new table based on the objects within the given collection.
    # 
    # Configuration options:
    # * <tt>:class</tt> - The actual class of the objects contained within the
    #   collection. This is used to help build the header columns.
    # * <tt>:header</tt> - Whether or not to display a header. Default is true.
    # * <tt>:footer</tt> - Whether or not to display a footer. Default is false.
    def initialize(collection, options = {}, html_options = {}) #:nodoc:
      super(html_options)
      
      options.assert_valid_keys(
        :class,
        :footer,
        :header
      )
      @options = options.reverse_merge(
        :header => true,
        :footer => false
      )
      
      @html_options.reverse_merge!(
        :cellspacing => '0',
        :cellpadding => '0'
      )
      
      @header = Header.new(collection, options[:class])
      @body = Body.new(collection, @header)
      @footer = Footer.new(collection)
    end
    
    # Builds the table by rendering a header (if enabled), body, and footer (if enabled).
    def build(&block)
      @body.build # Build with the defaults
      
      elements = []
      elements << @header.builder if @options[:header]
      elements << @body
      elements << @footer if @options[:footer]
      
      yield *elements if block_given?
      
      @content = ''
      elements.each {|element| @content << element.html}
      @content
    end
    
    private
      def tag_name
        'table'
      end
      
      def content
        @content
      end
  end
end
