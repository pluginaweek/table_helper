require 'table_helper/row'

module TableHelper
  # Represents a single row within the body of a table.  The row can consist
  # of either data cells or header cells. 
  # 
  # == Alternating rows
  # 
  # Alternating rows can be automated by setting the +alternate+ property.
  # For example,
  # 
  #   r = BodyRow.new
  #   r.alternate = true
  class BodyRow < Row
    # True if this is an alternating row, otherwise false.  Default is false.
    attr_accessor :alternate
    
    def initialize(object, header) #:nodoc:
      super()
      
      @header = header
      @alternate = false
      @html_options[:class] = ('row ' + @html_options[:class].to_s).strip
      
      # For each column defined in the table, see if we can prepopulate the
      # cell based on the data in the object.  If not, we can at least
      # provide shortcut accessors to the cell
      @header.column_names.each do |column|
        if object.respond_to?(column)
          cell(column, object.send(column))
        else
          builder.define_cell(column)
        end
      end
    end
    
    # Generates the html for this row in additional to the border row
    # (if specified)
    def html
      original_options = @html_options.dup
      @html_options[:class] = (@html_options[:class].to_s + ' alternate').strip if alternate
      html = super
      @html_options = original_options
      html
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
          else
            cell = Cell.new(column, '', :class => 'empty')
          end
          
          html << cell.html
        end
        
        html
      end
  end
end
