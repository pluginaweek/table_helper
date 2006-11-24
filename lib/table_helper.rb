module PluginAWeek #:nodoc:
  module Helpers #:nodoc:
    # Provides a set of methods for working with tables and especially tables
    # generates from a collection of ActiveRecord objects.  The following is an
    # example of a table that lists a series of attributes for each object.
    # 
    #  <%
    #    table = collection_table(@posts, {:alternate => :odd}, :id => 'posts', :class => 'summary') do |t|
    #      t.column :title, 'Title'
    #      t.column :category, 'Category'
    #      t.column :author, 'Author'
    #      t.column :publish_date, 'Date<br \>Published'
    #      t.column :num_comments, '# Comments'
    #      t.column :num_trackbacks, '# Trackbacks'
    #    end
    #    table.build do |row, post, index|
    #      row.cell :title, "<div class=\"wrapped\">#{post.title}</div>"
    #      row.cell :category, post.category.name
    #      row.cell :author, post.author.name
    #      row.cell :publish_date, time_ago_in_words(post.published_on)
    #      row.cell :num_comments, post.comments.empty? ? '-' : post.comments.size
    #      row.cell :num_trackbacks, post.trackbacks.empty? ? '-' : post.trackbacks.size
    #    end
    #  %>
    # 
    # ...is compiled to (formatted here for the sake of sanity):
    # 
    #  <table cellpadding="0" cellspacing="0" class="summary alternate" id="posts">
    #  <thead>
    #   <tr class="header row">
    #     <th class="title" scope="col">Title</th><th class="category" scope="col">Category</th>
    #     <th class="author" scope="col">Author</th><th class="publish_date" scope="col">Date<br \>Published</th>
    #     <th class="num_comments" scope="col"># Comments</th>
    #     <th class="num_trackbacks" scope="col"># Trackbacks</th>
    #   </tr>
    #   </thead>
    #   <tbody>
    #     <tr class="row">
    #       <td class="title"><div class="wrapped">Open-source projects: The good, the bad, and the ugly</div></td>
    #       <td class="category">General</td>
    #       <td class="author">John Doe</td>
    #       <td class="publish_date">23 days</td>
    #       <td class="num_comments">-</td>
    #       <td class="num_trackbacks">-</td>
    #     </tr>
    #     <tr><td colspan="6"><div class="horizontal_border"><!-- --></div></td></tr>
    #     <tr class="alt_row">
    #       <td class="title"><div class="wrapped">5 reasons you should care about Rails</div></td>
    #       <td class="category">Rails</td><td class="author">John Q. Public</td>
    #       <td class="publish_date">21 days</td>
    #       <td class="num_comments">-</td>
    #       <td class="num_trackbacks">-</td>
    #     </tr>
    #     <tr><td colspan="6"><div class="horizontal_border"><!-- --></div></td></tr>
    #     <tr class="row">
    #       <td class="title"><div class="wrapped">Deprecation: Stop digging yourself a hole</div></td>
    #       <td class="category">Rails</td>
    #       <td class="author">Jane Doe</td>
    #       <td class="publish_date">17 days</td>
    #       <td class="num_comments">-</td>
    #       <td class="num_trackbacks">-</td>
    #     </tr>
    #     <tr><td colspan="6"><div class="horizontal_border"><!-- --></div></td></tr>
    #     <tr class="alt_row">
    #       <td class="title"><div class="wrapped">Jumpstart your Rails career at RailsConf 2007</div></td>
    #       <td class="category">Conferences</td>
    #       <td class="author">Jane Doe</td>
    #       <td class="publish_date">4 days</td>
    #       <td class="num_comments">-</td>
    #       <td class="num_trackbacks">-</td>
    #     </tr>
    #     <tr><td colspan="6"><div class="horizontal_border"><!-- --></div></td></tr>
    #     <tr class="row">
    #       <td class="title"><div class="wrapped">Getting some REST</div></td>
    #       <td class="category">Rails</td>
    #       <td class="author">John Doe</td>
    #       <td class="publish_date">about 18 hours</td>
    #       <td class="num_comments">-</td>
    #       <td class="num_trackbacks">-</td>
    #     </tr>
    #   </tbody>
    #   </table>
    module TableHelper
      # 
      # 
      # Configuration options:
      # * <tt>alternate</tt> - If set to :odd or :even, every odd or even-numbered row will have the class 'alt_row' appended to its html attributes, respectively.  Default is nil.
      # * <tt>row_border</tt> - If set to :before, border rows will be generated before each normal row.  If set to :after or true, border rows will be generated after each normal row.  Default is :after.
      # * <tt>header</tt> - Specify if a header (thead) should be built into the table.  Default is true.
      # * <tt>footer</tt> - Specify if a footer (tfoot) should be built into the table.  Default is false.
      # * <tt>no_content_on_empty</tt> - Specify if all generated content should be replaced with a "no content" view of the table if the collection is empty.  If set to true, the header, body, and footer
      # will be be built.  Instead, the content in CollectionTable's no_content_caption
      def collection_table(collection, options = {}, html_options = {}, &block)
        CollectionTable.new(collection, options, html_options, &block)
      end
      
      # Represents a single cell within a table.  This can either be a regular
      # row cell (td) or a header cell (th).  By default, all cells will have
      # their column name appended to the cell's class value.
      # 
      # For example,
      # 
      #   Cell.new('td', :author, 'John Doe')
      # 
      # ...would generate the following tag:
      # 
      #   <td class="author">John Doe</td>
      # 
      # and
      # 
      #   Cell.new('th', :author, 'Author Name')
      # 
      # ...would generate the following tag:
      # 
      #   <th class="author">Author Name</th>
      class Cell
        include ActionView::Helpers::TagHelper
        
        class << self
          # An empty data cell
          def empty_data
            @empty_data ||= new('td', :empty, '')
          end
          
          # An empty header cell
          def empty_header
            @empty_header ||= new('th', :empty, '')
          end
        end
        
        def initialize(tag_name, class_name, content = class_name.titleize, html_options = {}) #:nodoc
          html_options.set_or_append(:class, class_name.to_s)
          
          @tag_name, @content, @html_options = tag_name, content, html_options
        end
        
        # Builds the html representation of the cell
        def build
          content_tag(@tag_name, @content, @html_options)
        end
      end
      
      # Represents a single row within a table.  A row can consist of either
      # data cells (td) or header cells (th).  
      class Row
        include ActionView::Helpers::TagHelper
        
        # An optional border that can be added to the row
        attr_reader :border
        
        # The collection of cells in the order that they will be rendered
        attr_reader :cells
        
        # Configuration options:
        # <tt>alternate</tt> - Specify if this is an alternating row.  Default is false.
        # <tt>border</tt> - Specify whether a border should be used.  Default is nil (no border).
        def initialize(options = {}) #:nodoc:
          options.assert_valid_keys(
            :alternate,
            :border
          )
          @options = {
            :alternate => false
          }.update(options)
          
          @border = Border.new
          @cells = ActiveSupport::OrderedHash.new
          @html_options = {}
        end
        
        # Gets the html option for the row
        def [](option)
          @html_options[option.to_sym]
        end
        
        # Sets the html option for the cell
        def []=(option, value)
          @html_options[option.to_sym] = value
        end
        
        # Builds a new data cell (i.e. <td>).  The class name will be
        # automatically merged into the cell's html options in addition to any
        # classes already defined.
        # 
        # For example,
        # 
        #   row.cell :author, 'John Doe'
        # 
        # ...would generate the following tag:
        # 
        #   <td class="author">John Doe</td>
        def cell(class_name, content = '', html_options = {})
          @cells[class_name] = Cell.new('td', class_name, content, html_options)
        end
        
        # Builds a new header cell (i.e. <th>).  The class name will be
        # automatically merged into the cell's html options in addition to any
        # classes already defined.
        # 
        # For example,
        # 
        #   row.header :author, 'Author Name', :class => 'title'
        # 
        # ...would generate the following tag:
        # 
        #   <th class="title author">Author Name</th>
        def header(class_name, content = '', html_options = {})
          @cells[class_name] = Cell.new('th', class_name, content, html_options)
        end
        
        # Builds the row, including the border if it was specified to be used.
        # You can explicitly set the order and number of columns by passing in
        # an array of column names.  If a specific column is not found, a blank
        # cell is rendered.
        def build(columns = nil)
          row_html = ''
          
          if columns
            columns.each do |class_name|
              row = @cells[class_name] || Cell.empty_data
              row_html << row.build
            end
          else
            @cells.values.each do |cell|
              row_html << cell.build
            end
          end
          
          options = @html_options.dup
          options.set_or_append(:class, @options[:alternate] ? 'alt_row' : 'row')
          row_html = content_tag('tr', row_html, options)
          
          if @options[:border] == :before
            build_border(columns) + row_html
          elsif @options[:border] == :after
            row_html + build_border(columns)
          else
            row_html
          end
        end
        
        private
        # Builds the border row and returns the html generated for it
        def build_border(columns = nil)
          @border.cell[:colspan] = columns.size if columns && @border.cell[:colspan].nil?
          @border.build
        end
      end
      
      # Represents a border within a table.  This is a special class because it
      # allows you to define custom borders like dotted lines that otherwise
      # could not be used in browsers that do not support these types of line
      # styles (for example, Internet Explorer)
      class Border
        include ActionView::Helpers::TagHelper
        
        def initialize #:nodoc:
          @row_options, @cell_options = {}, {}
        end
        
        # Gets the html option for the border
        def [](option)
          @row_options[option]
        end
        
        # Sets the html option for the border
        def []=(option, value)
          @row_options[option] = value
        end
        
        # Gets the html options that will be used for the actual td cell within
        # the row
        def cell
          @cell_options
        end
        
        # Builds the html representation of the border
        def build
          html = '<!-- -->'
          html = content_tag('div', html, :class => 'horizontal_border')
          html = content_tag('td', html, @cell_options)
          
          content_tag('tr', html, @row_options)
        end
      end
      
      # Represents a table that is displaying data for multiple objects within
      # a collection.  Each object is (usually) rendered the same way by
      # providing the CollectionTable with a block that specifies the data in
      # each cell when building the table.  
      class CollectionTable
        include ActionView::Helpers::TagHelper
        
        # The content to display when there are no records in the collection
        attr_accessor :no_content_caption
        
        # The collection of columns that will be used in the header and to
        # determine the order in which cells are rendered
        attr_reader :columns
        
        def initialize(collection, options = {}, html_options = {}) #:nodoc:
          @collection = collection
          
          options.assert_valid_keys(
            :alternate,
            :row_border,
            :header,
            :footer,
            :no_content_on_empty
          )
          @options = {
            :alternate => :odd,
            :row_border => :after,
            :header => true,
            :footer => false,
            :no_content_on_empty => true
          }.update(options)
          
          raise ArgumentError, ':alternate must be set to :odd or :even' if ![:odd, :even].include?(@options[:alternate])
          raise ArgumentError, ':row_border must be set to :before or :after' if ![:before, :after].include?(@options[:row_border])
          
          @html_options = {
            :cellspacing => '0',
            :cellpadding => '0'
          }.update(html_options)
          @html_options.set_or_append(:class, 'alternate') if options[:alternate]
          
          @columns = ActiveSupport::OrderedHash.new
          @no_content_caption = "Nothing to see here... move along"
          
          yield self if block_given?
        end
        
        # Creates a new column with the specified caption.  Columns should be
        # defined in the order in which they will be rendered.
        # 
        # The caption determines what will be displayed in each cell of the
        # header (if the header is rendered).  For example,
        # 
        #   table = collection_table(@posts) do |t|
        #     t.column :title, 'Title'
        #   end
        # 
        # ...will generate a table with 1 column
        def column(class_name, caption)
          @columns[class_name] = caption
        end
        
        # Builds the header and body.  The footer will be ignored regardless of
        # whether it was set to true when creating the table.
        # 
        # This method expects a block that defines the content within each cell
        # in a row.  See build_body for more information.
        def build(&block)
          build_body(true, &block)
        end
        
        # Builds the header of the table.  The header row will be wrapped within
        # a thead tag.  If the size of the collection is 0 and :no_content_on_empty
        # was set to true, then the thead will be hidden.
        def build_header
          row = Row.new(:border => (@options[:dotted_header] ? :after : false))
          row[:class] = 'header'
          columns.each do |class_name, caption|
            row.header class_name, caption, :scope => 'col'
          end
          html = row.build(columns.keys)
          
          options = {}
          options[:style] = 'display: none;' if @collection.size == 0 && @options[:no_content_on_empty]
          content_tag('thead', html, options)
        end
        
        # Builds the body of the table.  This includes the actual data that is
        # generated for each object in the collection.
        # 
        # build_body expects a block that defines the data in each cell.  Each
        # iteration of the block will provide the object being rendered, the row
        # within the table that will be built and the index of the object.  For
        # example,
        # 
        #   table.build do |row, post, index|
        #     row.cell :title, "<div class=\"wrapped\">#{post.title}</div>"
        #     row.cell :category, post.category.name
        #   end
        # 
        # In addition, to specifying the data, you can also modify the html
        # options of the row.  For more information on doing this, see the Row
        # class.
        # 
        # If the size of the collection is 0 and :no_content_on_empty was set
        # to true, then the actual body will be replaced by a single row
        # containing the html that was stored in the CollectionTable's
        # no_content_caption.
        def build_body(dump_table = true, &block)
          html = ''
          
          # Display nothing if there are no objects to display
          if @collection.size == 0
            row = Row.new
            row.cell :no_content, no_content_caption, :colspan => columns.size
            html << row.build
          else
            @collection.each_with_index do |object, i|
              html << build_row(object, i, &block)
            end
          end
          
          @body = content_tag('tbody', html)
          
          if dump_table
            content_tag('table', build_header + @body, @html_options)
          end
        end
        
        # Builds a row (tr) for an object in the table.  Borders will NOT be
        # built for rows if the borders after being generated after the row and
        # this is the last row or borders are being generated before the row and
        # this is the first row.
        # 
        # The provided block should set the values for each cell in the row.
        def build_row(object, index = @collection.index(object), &block)
          alternate = @options[:alternate]
          alternate = alternate ? index.send("#{alternate}?") : false
          
          row_options = {:alternate => alternate}
          
          border = @options[:row_border]
          if border && (index != @collection.size-1 && border == :after || index != 0 && border == :before)
            row_options[:border] = border
          end
          
          row = Row.new(row_options)
          
          yield row, object, index
          
          row.build(columns.keys)
        end
        
        # Builds the footer of the table.  The footer generally consists of a
        # summary of the data in the body.  This row will be wrapped inside of
        # a tfoot tag.  If the size of the collection is 0 and
        # :no_content_on_empty was set to true, then the row will be hidden.
        # 
        # build_footer expects a block that defines the data in each cell.  
        # There will only be a single iteration of the block.  For example,
        # 
        #   table.build_footer do |footer|
        #     footer.cell :summary, 'Summary'
        #     footer.cell :sum, @posts.size
        #   end
        # 
        # build_footer should be invoked AFTER build_body.  The result of
        # build_footer should then be used as output to your template.  It will
        # contain the header, body, and footer wrapped inside of a table tag.
        def build_footer(&block)
          row = Row.new(:border => (@options[:dotted_header] ? :after : false))
          row[:class] = 'footer'
          
          yield row
          
          html = row.build(columns.keys)
          
          options = {}
          options[:style] = 'display: none;' if @collection.size == 0 && @options[:no_content_on_empty]
          footer = content_tag('tfoot', html, options)
          
          content_tag('table', build_header + @body + footer, @html_options)
        end
      end
    end
  end
end

ActionController::Base.class_eval do
  helper PluginAWeek::Helpers::TableHelper
end