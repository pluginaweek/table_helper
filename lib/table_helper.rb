module PluginAWeek #:nodoc:
  module Helpers #:nodoc:
    module TableHelper
      #
      #
      def collection_table(collection, options = {}, html_options = {})
        CollectionTable.new(collection, options, html_options)
      end
      
      #
      #
      class Cell
        include ActionView::Helpers::TagHelper
        
        #
        #
        def initialize(tag_name, class_name, value, html_options = {})
          html_options.set_or_append(:class, class_name.to_s)
          
          @tag_name, @value, @html_options = tag_name, value, html_options
        end
        
        #
        #
        def build
          content_tag(@tag_name, @value, @html_options)
        end
      end
      
      #
      #
      class Row
        include ActionView::Helpers::TagHelper
        
        #
        #
        attr_accessor :border
        
        #
        #
        def initialize(options = {})
          @options = {
            :alternate => false
          }.update(options)
          
          self.border = Border.new
          @cells, @html_options = {}, {}
        end
        
        #
        #
        def []=(option, value)
          @html_options[option] = value
        end
        
        #
        #
        def cell(class_name, value = '', html_options = {})
          @cells[class_name] = Cell.new('td', class_name, value, html_options)
        end
        
        #
        #
        def header(class_name, value = '', html_options = {})
          @cells[class_name] = Cell.new('th', class_name, value, html_options)
        end
        
        #
        #
        def build(columns = nil)
          row_html = ''
          border_html = ''
          
          if @options[:border]
            @border.cell[:colspan] = columns.size if columns && @border.cell[:colspan].nil?
            border_html = @border.build
          end
          
          if columns
            columns.each do |class_name|
              row_html << @cells[class_name].build
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
            border_html + row_html
          else
            row_html + border_html
          end
        end
      end
      
      #
      #
      class Border
        include ActionView::Helpers::TagHelper
        
        #
        #
        def initialize
          @row_options, @cell_options = {}, {}
        end
        
        #
        #
        def []=(option, value)
          @row_options[option] = value
        end
        
        #
        #
        def cell
          @cell_options
        end
        
        #
        #
        def build
          html = '<!-- -->'
          html = content_tag('div', html, :class => 'horizontal_border')
          html = content_tag('td', html, @cell_options)
          
          content_tag('tr', html, @row_options)
        end
      end
      
      #
      #
      class CollectionTable
        include ApplicationHelper
        include ActionView::Helpers::TagHelper
        
        attr_accessor :no_content_caption
        attr_accessor :columns
        
        #
        #
        def initialize(collection, options = {}, html_options = {})
          @collection = collection
          
          @options = {
            :row_border => :after
          }.update(options)
          
          html_options = {
            :cellspacing => '0',
            :cellpadding => '0'
          }.update(html_options)
          html_options.set_or_append(:class, 'alternate') if options[:alternate]
          @html_options = html_options
          
          @columns = OrderedHash.new
          @no_content_caption = "Nothing to see here... move along"
          
          yield self if block_given?
        end
        
        #
        #
        def column(class_name, caption)
          @columns[class_name] = caption
        end
        
        #
        #
        def build(&block)
          html = ''
          
          # Create the header
          header_row = Row.new(:border => (@options[:dotted_header] ? :after : false))
          header_row[:class] = 'header'
          columns.each do |class_name, caption|
            header_row.header class_name, caption, :scope => 'col'
          end
          header_html = header_row.build(columns.keys)
          
          header_options = {}
          header_options[:style] = 'display: none;' if @collection.size == 0
          html << content_tag('thead', header_html, header_options)
          
          body_html = ''
          
          # Display nothing if there are no objects to display
          if @collection.size == 0
            row = Row.new
            row.cell :no_content, no_content_caption, :colspan => columns.size
            body_html << row.build
          else
            @collection.each_with_index do |object, i|
              body_html << build_row(object, i, &block)
            end
          end
          
          html << content_tag('tbody', body_html)
          
          content_tag('table', html, @html_options)
        end
        
        #
        #
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
      end
    end
  end
end

ActionController::Base.class_eval do
  helper PluginAWeek::Helpers::TableHelper
end