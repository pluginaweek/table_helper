require 'table_helper/row'

module PluginAWeek #:nodoc:
  module Helpers #:nodoc:
    module TableHelper
      # Represents a single row within the body of a table.  The row can consist
      # of either data cells or header cells. 
      # 
      # == Borders
      # 
      # Each row has an optional special border row that can be generated either
      # immediately before or immediately after this row.  A separate border row
      # is usually used when you cannot express borders in the css of the row
      # containing the data (e.g. dotted borders in Internet Explorer).
      # 
      # To modify the properties of the border, you can access +row.border+ like
      # so:
      # 
      #   r = BodyRow.new
      #   r.border_type = :before
      #   r.border[:style] = 'color: #ff0000;'
      # 
      # == Alternating rows
      # 
      # Alternating rows can be automated by setting the +alternate+ property.
      # For example,
      # 
      #   r = BodyRow.new
      #   r.alternate = true
      class BodyRow < Row
        # An optional border that can be added to the row
        attr_reader   :border
        
        # Set what type of row border to use for this row.  If set to :before or
        # :after, then the border will be generated before or after this row,
        # respectively.  Otherwise, no border will be generated.
        attr_accessor :border_type
        
        # True if this is an alternating row, otherwise false.  Default is false.
        attr_accessor :alternate
        
        def initialize(object, header) #:nodoc:
          super()
          
          @header = header
          @border = Border.new(header)
          @alternate = false
          @html_options.set_or_prepend(:class, 'row')
          
          # For each column defined in the table, see if we can prepopulate the
          # cell based on the data in the object.  If not, we can at least
          # provide shortcut accessors to the cell
          @header.column_names.each do |column|
            if object.respond_to?(column)
              cell(column, object.send(column))
            else
              define_cell_accessor(column)
            end
          end
        end
        
        # Sets the type of border to use for this row.  If set to :before, then
        # the border row will be generated *before* this row.  If set to :after,
        # it will be genereated *after* this row.
        def border_type=(value)
          raise ArgumentError, 'border_type must be set to :before or :after' if value && ![:before, :after].include?(value)
          @border_type = value
        end
        
        # Generates the html for this row in additional to the border row
        # (if specified)
        def html
          original_options = @html_options.dup
          @html_options.set_or_append(:class, 'alternate') if alternate
          
          html = super
          
          @html_options = original_options
          
          if border_type == :before
            border.html + html
          elsif border_type == :after
            html + border.html
          else
            html
          end
        end
        
        private
        # Builds the row's cells based on the order of the columns in the
        # header.  If a cell cannot be found for a specific column, then a blank
        # cell is rendered.
        def content
          number_to_skip = 0 # Keeps track of the # of columns to skip
          
          html = ''
          @header.column_names.each do |column|
            number_to_skip -= 1 and next if number_to_skip > 0
            
            if cell = @cells[column]
              number_to_skip = (cell[:colspan] || 1) - 1
            # elsif @header.send(column)
            else
              cell = Cell.new(column, '', :class => 'empty')
            end
            
            html << cell.html
          end
          
          html
        end
      end
    end
  end
end
