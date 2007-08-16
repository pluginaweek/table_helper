require 'table_helper/row'

module PluginAWeek #:nodoc:
  module Helpers #:nodoc:
    module TableHelper #:nodoc:
      # Represents the header of the table.  In HTML, you can think of this as
      # the <thead> tag of the table.
      class Header < HtmlElement
        # The actual header row
        attr_reader   :row
        
        # Whether or not the header should be hidden when the collection is
        # empty.  Default is true.
        attr_accessor :hide_when_empty
        
        # Creates a new header for a collection that contains objects of the
        # given class.
        # 
        # If the class is known, then the header will be pre-filled with
        # the columns defined in that class (assuming it's an ActiveRecord
        # class).
        def initialize(collection, klass = nil)
          super()
          
          @collection = collection
          @row = Row.new
          
          @hide_when_empty = true
          @customized = true
          
          # If we know what class the objects in the collection are and we can
          # figure out what columns are defined in that class, then we can
          # pre-fill the header with those columns so that the user doesn't
          # have to
          if klass && klass.respond_to?(:column_names)
            klass.column_names.each {|name| column(name)}
            @customized = false
          end
        end
        
        # Gets the names of all of the columns being displayed in the table
        def column_names
          row.cell_names
        end
        
        # Creates a new column with the specified caption.  Columns must be
        # defined in the order in which they will be rendered.
        # 
        # The caption determines what will be displayed in each cell of the
        # header (if the header is rendered).  For example,
        # 
        #   header.column :title, 'The Title'
        # 
        # ...will create a column the displays "The Title" in the cell.
        # 
        # = Setting html options
        # 
        # In addition to customizing the content of the column, you can also
        # specify html options like so:
        # 
        #   header.column :title, 'The Title', :class => 'pretty'
        def column(name, *args)
          # Clear the header row if this is being customized by the user
          if !@customized
            @customized = true
            
            # Remove all of the shortcut methods
            column_names.each do |column|
              begin
              klass = class << self; self; end
              klass.class_eval do
                remove_method(column)
              end
              rescue Exception => e
              end
            end
            
            @row.clear
          end
          
          column = @row.cell(name, *args)
          column.content_type = :header
          column[:scope] ||= 'col'
          
          # Define a shortcut method to the cell
          name = name.to_s.gsub('-', '_')
          unless respond_to?(name)
            instance_eval <<-end_eval
              def #{name}(*args)
                @row.#{name}(*args)
              end
            end_eval
          end
          
          column
        end
        
        # Creates and returns the generated html for the header
        def html
          html_options = @html_options.dup
          html_options[:style] = 'display: none;' if @collection.size == 0 && hide_when_empty
          
          content_tag(tag_name, content, html_options)
        end
        
        private
        def tag_name
          'thead'
        end
        
        def content
          @row.html
        end
      end
    end
  end
end