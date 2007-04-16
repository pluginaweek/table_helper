require 'table_helper/html_element'
require 'table_helper/header'
require 'table_helper/body'
require 'table_helper/footer'

module PluginAWeek #:nodoc:
  module Helpers #:nodoc:
    module TableHelper #:nodoc:
      # Represents a table that is displaying data for multiple objects within
      # a collection.
      class CollectionTable < HtmlElement
        def initialize(collection, options = {}, html_options = {}) #:nodoc:
          super(html_options)
          
          options.assert_valid_keys(
            :class,
            :footer,
            :header
          )
          @options = options.reverse_merge(
            :footer => false,
            :header => true
          )
          
          @html_options.reverse_merge!(
            :cellspacing => '0',
            :cellpadding => '0'
          )
          
          @header = Header.new(collection, options[:class] || class_for_collection(collection))
          @body = Body.new(collection, @header)
          @footer = Footer.new(collection)
        end
        
        # Builds the table by rendering a header, body, and footer.
        def build(&block)
          @body.build # Build with the defaults
          
          elements = []
          elements << @header if @options[:header]
          elements << @body
          elements << @footer if @options[:footer]
          
          yield *elements if block_given?
          
          @content = ''
          elements.each {|element| @content << element.html}
          @content
        end
        
        private
        def class_for_collection(collection)
          if collection.respond_to?(:proxy_reflection)
            collection.proxy_reflection.klass
          elsif !collection.empty?
            collection.first.class
          end
        end
        
        def tag_name
          'table'
        end
        
        def content
          @content
        end
      end
    end
  end
end