require 'table_helper/row'

module TableHelper
  # Represents the header of the table.  In HTML, you can think of this as
  # the <tfoot> tag of the table.
  class Footer < HtmlElement
    # The actual footer row
    attr_reader :row
    
    delegate  :cell,
                :to => :row
    
    # Whether or not the footer should be hidden when the collection is
    # empty.  Default is true.
    attr_accessor :hide_when_empty
    
    def initialize(collection) #:nodoc:
      super()
      
      @collection = collection
      @row = Row.new
      @hide_when_empty = true
    end
    
    def html #:nodoc:
      html_options = @html_options.dup
      html_options[:style] = 'display: none;' if @collection.empty? && hide_when_empty
      
      content_tag(tag_name, content, html_options)
    end
    
    private
      def tag_name
        'tfoot'
      end
      
      # Generates the html for the footer.  The footer generally consists of a
      # summary of the data in the body.  This row will be wrapped inside of
      # a tfoot tag.  If the collection is empty and hide_when_empty was set
      # to true, then the footer will be hidden.
      def content
        @row.html
      end
  end
end
