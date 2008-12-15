require 'table_helper/row'

module TableHelper
  # Provides a blank class that can be used to build the columns for a header
  class HeaderBuilder < BlankSlate #:nodoc:
    reveal :respond_to?
    
    attr_reader :header
    
    # Creates a builder for the given header
    def initialize(header)
      @header = header
    end
    
    # Proxies all missed methods to the header
    def method_missing(*args)
      header.send(*args)
    end
    
    # Defines the accessor method for the given column name.  For example, if
    # a column with the name :title was defined, then the column would be able
    # to be read and written like so:
    # 
    #   header.title               #=> Accesses the title
    #   header.title "Page Title"  #=> Creates a new column with "Page Title" as the content
    def define_column(name)
      method_name = name.to_s.gsub('-', '_')
      
      klass = class << self; self; end
      klass.class_eval do
        define_method(method_name) do |*args|
          header.row.builder.__send__(method_name, *args)
        end
      end unless klass.method_defined?(method_name)
    end
    
    # Removes the definition for the given cp;i,m
    def undef_column(name)
      klass = class << self; self; end
      klass.class_eval do
        remove_method(name.gsub('-', '_'))
      end
    end
  end
  
  # Represents the header of the table.  In HTML, you can think of this as
  # the <thead> tag of the table.
  class Header < HtmlElement
    # The actual header row
    attr_reader :row
    
    # The proxy class used externally to build the actual columns
    attr_reader :builder
    
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
      @builder = HeaderBuilder.new(self)
      
      @hide_when_empty = true
      @customized = true
      
      # If we know what class the objects in the collection are and we can
      # figure out what columns are defined in that class, then we can
      # pre-fill the header with those columns so that the user doesn't
      # have to
      klass ||= class_for_collection(collection)
      if klass && klass.respond_to?(:column_names)
        klass.column_names.each {|name| column(name)}
        @customized = false
      end
    end
    
    # The current columns in this header, in the order in which they will be built
    def columns
      row.cells
    end
    
    # Gets the names of all of the columns being displayed in the table
    def column_names
      row.cell_names
    end
    
    # Clears all of the current columns from the header
    def clear
      # Remove all of the shortcut methods
      column_names.each {|name| builder.undef_column(name)}
      row.clear
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
      unless @customized
        @customized = true
        clear
      end
      
      column = row.cell(name, *args)
      column.content_type = :header
      column[:scope] ||= 'col'
      
      builder.define_column(name)
      
      column
    end
    
    # Creates and returns the generated html for the header
    def html
      html_options = @html_options.dup
      html_options[:style] = 'display: none;' if @collection.empty? && hide_when_empty
      
      content_tag(tag_name, content, html_options)
    end
    
    private
      # Finds the class representing the objects within the collection
      def class_for_collection(collection)
        if collection.respond_to?(:proxy_reflection)
          collection.proxy_reflection.klass
        elsif !collection.empty?
          collection.first.class
        end
      end
      
      def tag_name
        'thead'
      end
      
      def content
        @row.html
      end
  end
end
