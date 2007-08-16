require 'table_helper/cell'

module PluginAWeek #:nodoc:
  module Helpers #:nodoc:
    module TableHelper #:nodoc:
      # Represents a single row within a table.  A row can consist of either
      # data cells or header cells.
      class Row < HtmlElement
        def initialize #:nodoc:
          super
          
          @cells = ActiveSupport::OrderedHash.new
        end
        
        # Creates a new cell with the given name and generates shortcut
        # accessors for the method.
        def cell(name, *args)
          name = name.to_s if name
          
          cell = Cell.new(name, *args)
          @cells[name] = cell
          
          define_cell_accessor(name) if name && !respond_to?(name)
          
          cell
        end
        
        # The names of all cells in this row
        def cell_names
          @cells.keys
        end
        
        # Clears all of the current cells from the row, removing 
        def clear
          cell_names.each do |name|
          begin
            klass = class << self; self; end
            klass.class_eval do
              remove_method(name)
            end
          rescue Exception => e
          end
          end
          
          @cells.clear
        end
        
        private
        # Defines the accessor method for the given cell name.  For example, if
        # a cell with the name :title was defined, then the cell would be able
        # to be read and written like so:
        # 
        #   row.title               #=> Accesses the title
        #   row.title "Page Title"  #=> Creates a new cell with "Page Title" as the content
        def define_cell_accessor(name)
          instance_eval <<-end_eval
            def #{name.gsub('-', '_')}(*args)
              if args.empty?
                @cells[#{name.inspect}]
              else
                cell(#{name.inspect}, *args)
              end
            end
          end_eval
        end
        
        def tag_name
          'tr'
        end
        
        def content
          @cells.values.map(&:html).join
        end
      end
    end
  end
end