require 'table_helper/cell'

module PluginAWeek #:nodoc:
  module Helpers #:nodoc:
    module TableHelper #:nodoc:
      # Represents a border within a table.  This is a special class because it
      # allows you to define custom borders like dotted lines that otherwise
      # could not be used in browsers that do not support these types of line
      # styles (for example, Internet Explorer).
      class Border < HtmlElement
        # The cell in the border row containing the content that will be
        # rendered
        attr_accessor :cell
        
        def initialize(header) #:nodoc:
          super()
          
          @header = header
          self.cell = Cell.new(nil, content_tag('div', '<!-- -->'))
          self[:class] = 'border'
        end
        
        private
        def tag_name
          'tr'
        end
        
        def content
          cell = self.cell.dup
          cell[:colspan] = @header.column_names.size if @header.column_names.size > 1 && !cell[:colspan]
          cell.html
        end
      end
    end
  end
end