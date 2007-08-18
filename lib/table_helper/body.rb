require 'table_helper/body_row'
require 'table_helper/border'

module PluginAWeek #:nodoc:
  module Helpers #:nodoc:
    module TableHelper
      # Represents the body of the table.  In HTML, you can think of this as
      # the <tbody> tag of the table.
      class Body < HtmlElement
        # If set to :odd or :even, every odd or even-numbered row will have the
        # class 'alternate' appended to its html attributes, respectively.
        # Default is nil.
        attr_accessor :alternate_rows
        
        # The caption to display in the collection is empty
        attr_accessor :empty_caption
        
        # If set to :before, border rows will be generated before each normal
        # row.  If set to :after or true, border rows will be generated after
        # each normal row.  Default is nil.
        attr_accessor :row_borders
        
        def initialize(collection, header) #:nodoc:
          super()
          
          @collection, @header = collection, header
          @empty_caption = 'No matches found.'
        end
        
        def alternate_rows=(value) #:nodoc:
          raise ArgumentError, 'alternate_rows must be set to :odd or :even' if value && ![:odd, :even].include?(value)
          @alternate_rows = value
        end
        
        # Builds the body of the table.  This includes the actual data that is
        # generated for each object in the collection.
        # 
        # build expects a block that defines the data in each cell.  Each
        # iteration of the block will provide the object being rendered, the row
        # within the table that will be built and the index of the object.  For
        # example,
        # 
        #   body.build do |row, post, index|
        #     row.title     "<div class=\"wrapped\">#{post.title}</div>"
        #     row.category  post.category.name
        #   end
        # 
        # In addition, to specifying the data, you can also modify the html
        # options of the row.  For more information on doing this, see the
        # BodyRow class.
        # 
        # If the collection is empty and +empty_caption+ is set on the Body,
        # then the actual body will be replaced by a single row containing the
        # html that was stored in +empty_caption+.
        # 
        # == Default Values
        # 
        # Whenever possible, the default value of a cell will be set to the
        # object's attribute with the same name as the cell.  For example,
        # if a Post consists of the attribute +title+, then the cell for the
        # title will be prepopulated with that attribute's value:
        # 
        #   body.build do |row, post index|
        #     row.category post.category.name
        #   end
        # 
        # +row.title+ is already set to post.category so there's no need to
        # manually set the value of that cell.  However, it is always possible
        # to override the default value like so:
        # 
        #   body.build do |row, post, index|
        #     row.title     link_to(post.title, post_url(post))
        #     row.category  post.category.name
        #   end
        def build(&block)
          @content = ''
          
          # Display nothing if there are no objects to display
          if @collection.empty? && @empty_caption
            row = Row.new
            row[:class] = 'no_content'
            
            html_options = {}
            html_options[:colspan] = @header.column_names.size if @header.column_names.size > 1
            row.cell nil, @empty_caption, html_options
            
            @content << row.html
          else
            @collection.each_with_index do |object, i|
              @content << build_row(object, i, &block)
            end
          end
          
          @content
        end
        
        # Builds a row for an object in the table.  Borders will *not* be built
        # for rows if the borders after being generated after the row and this
        # is the last row or borders are being generated before the row and this
        # is the first row.
        # 
        # The provided block should set the values for each cell in the row.
        def build_row(object, index = @collection.index(object), &block)
          alternate = alternate_rows ? index.send("#{@alternate_rows}?") : false
          
          if row_borders && (index != @collection.size-1 && row_borders == :after || index != 0 && row_borders == :before)
            border_type = row_borders
          end
          
          row = BodyRow.new(object, @header)
          row.alternate = alternate
          row.border_type = border_type
          
          yield row, object, index if block_given?
          
          row.html
        end
        
        def html #:nodoc:
          html_options = @html_options.dup
          html_options.set_or_append(:class, 'alternate') if alternate_rows
          
          content_tag(tag_name, content, html_options)
        end
        
        private
        def tag_name
          'tbody'
        end
        
        def content
          @content
        end
      end
    end
  end
end
