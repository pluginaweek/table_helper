module TableHelper
  # Represents a single cell within a table.  This can either be a regular
  # data cell (td) or a header cell (th).  By default, all cells will have
  # their column name appended to the cell's class attribute.
  # 
  # == Creating data cells
  # 
  #   Cell.new(:author, 'John Doe').build
  # 
  # ...would generate the following tag:
  # 
  #   <td class="author">John Doe</td>
  # 
  # == Creating header cells
  # 
  #   c = Cell.new(:author, 'Author Name')
  #   c.content_type = :header
  #   c.build
  # 
  # ...would generate the following tag:
  # 
  #   <th class="author">Author Name</th>
  class Cell < HtmlElement
    def initialize(class_name, content = class_name.to_s.titleize, html_options = {}) #:nodoc
      super(html_options)
      
      @content = content
      @html_options[:class] = ("#{class_name} " + @html_options[:class].to_s).strip if class_name
      
      self.content_type = :data
    end
    
    # Indicates what type of content will be stored in this cell.  This can
    # be set to either :data or :header.
    def content_type=(value)
      raise ArgumentError, "content_type must be set to :data or :header, was: #{value.inspect}" unless [:data, :header].include?(value)
      @content_type = value
    end
    
    private
      def tag_name
        @content_type == :data ? 'td' : 'th'
      end
      
      def content
        @content
      end
  end
end
