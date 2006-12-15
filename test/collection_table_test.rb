require File.dirname(__FILE__) + '/test_helper'

class PluginAWeek::Helpers::TableHelper::CollectionTable
  attr_accessor :options,
                :html_options,
                :body
end

class CollectionTableTest < Test::Unit::TestCase
  CollectionTable = PluginAWeek::Helpers::TableHelper::CollectionTable
  
  def setup
    @collection = [
      'first',
      'second',
      'third'
    ]
    @table = CollectionTable.new(@collection)
  end
  
  def test_invalid_option
    assert_raise(ArgumentError) {CollectionTable.new([], :invalid => true)}
  end
  
  def test_invalid_alternate_value
    assert_raise(ArgumentError) {CollectionTable.new([], :alternate => true)}
  end
  
  def test_valid_alternate_value
    assert_nothing_raised {
      CollectionTable.new([], :alternate => :odd)
      CollectionTable.new([], :alternate => :even)
    }
  end
  
  def test_invalid_row_border_value
    assert_raise(ArgumentError) {CollectionTable.new([], :row_border => true)}
  end
  
  def test_valid_row_border_value
    assert_nothing_raised {
      CollectionTable.new([], :row_border => :before)
      CollectionTable.new([], :row_border => :after)
    }
  end
  
  def test_default_columns
    expected_columns = [] # Not a real hash since it's ordered
    assert_equal expected_columns, @table.columns
  end
  
  def test_default_options
    expected_options = {
      :header => true,
      :footer => false,
      :no_content_on_empty => true
    }
    assert_equal expected_options, @table.options
  end
  
  def test_default_html_options
    expected_html_options = {
      :cellspacing => '0',
      :cellpadding => '0'
    }
    assert_equal expected_html_options, @table.html_options
  end
  
  def test_default_html_options_with_alternating
    t = CollectionTable.new([], :alternate => :odd)
    expected_html_options = {
      :cellspacing => '0',
      :cellpadding => '0',
      :class => 'alternate'
    }
    assert_equal expected_html_options, t.html_options
  end
  
  def test_default_html_options_with_alternating_and_preset_class
    t = CollectionTable.new([], {:alternate => :odd}, :class => 'summary')
    expected_html_options = {
      :cellspacing => '0',
      :cellpadding => '0',
      :class => 'alternate summary'
    }
    assert_equal expected_html_options, t.html_options
  end
  
  def test_default_no_content_caption
    assert_equal 'No matches found.', @table.no_content_caption
  end
  
  def test_yields_self_after_initialization
    CollectionTable.new([]) do |t|
      @created_table = t
    end
    
    assert_not_nil @created_table
  end
  
  def test_column_with_default_caption
    @table.column :name
    assert_equal 'Name', @table.columns[:name]
  end
  
  def test_column_with_custom_caption
    @table.column :name, 'Full Name'
    assert_equal 'Full Name', @table.columns[:name]
  end
  
  def test_order_of_multiple_columns
    @table.column :name
    @table.column :age
    
    expected_columns = [
      [:name, 'Name'],
      [:age, 'Age']
    ]
    assert_equal expected_columns, @table.columns
  end
  
  def test_build_header_with_defaults
    @table.column :name
    
    expected = <<-end_eval
<thead>
  <tr class="row header">
    <th class="name" scope="col">Name</th>
  </tr>
</thead>
end_eval
    assert_html_equal expected, @table.build_header
  end
  
  def test_build_header_with_no_rows_and_content_on_empty
    t = CollectionTable.new([], :no_content_on_empty => false)
    t.column :name
    
    expected = <<-end_eval
<thead>
  <tr class="row header">
    <th class="name" scope="col">Name</th>
  </tr>
</thead>
end_eval
    assert_html_equal expected, t.build_header
  end
  
  def test_build_header_with_no_rows_and_no_content_on_empty
    t = CollectionTable.new([], :no_content_on_empty => true)
    t.column :name
    
    expected = <<-end_eval
<thead style="display: none;">
  <tr class="row header">
    <th class="name" scope="col">Name</th>
  </tr>
</thead>
end_eval
    assert_html_equal expected, t.build_header
  end
  
  def test_build_header_with_multiple_columns
    @table.column :name
    @table.column :age
    
    expected = <<-end_eval
<thead>
  <tr class="row header">
    <th class="name" scope="col">Name</th>
    <th class="age" scope="col">Age</th>
  </tr>
</thead>
end_eval
    assert_html_equal expected, @table.build_header
  end
  
  def test_build_header_with_additional_options
    @table.column :name
    
    expected = <<-end_eval
<thead>
  <tr><td><div class="horizontal_border"><!-- --></div></td></tr>
  <tr class="row header">
    <th class="name" scope="col">Name</th>
  </tr>
</thead>
end_eval
    assert_html_equal expected, @table.build_header(:border => :before)
  end
  
  def test_build_header_with_html_options
    @table.column :name
    
    expected = <<-end_eval
<thead>
  <tr><td><div class="horizontal_border"><!-- --></div></td></tr>
  <tr bgcolor="red" class="row header">
    <th class="name" scope="col">Name</th>
  </tr>
</thead>
end_eval
    assert_html_equal expected, @table.build_header({:border => :before}, :bgcolor => 'red')
  end
  
  def test_build_row_default_index
    @table.column :name
    actual = @table.build_row('first') do |row, object, index|
      assert_equal 'first', object
      assert_equal 0, index
      
      row.cell :name, object
    end
    
    expected = <<-end_eval
<tr class="row">
  <td class="name">first</td>
</tr>
end_eval
    assert_html_equal expected, actual
  end
  
  def test_build_row_custom_index
    @table.column :name
    actual = @table.build_row('first', 1) do |row, object, index|
      assert_equal 'first', object
      assert_equal 1, index
      
      row.cell :name, object
    end
    
    expected = <<-end_eval
<tr class="row">
  <td class="name">first</td>
</tr>
end_eval
    assert_html_equal expected, actual
  end
  
  def test_build_row_alternate_even
    @table.options[:alternate] = :even
    
    @table.column :name
    actual = @table.build_row('first') do |row, object, index|
      row.cell :name, object
    end
    
    expected = <<-end_eval
<tr class="row alternate">
  <td class="name">first</td>
</tr>
end_eval
    assert_html_equal expected, actual
  end
  
  def test_build_row_alternate_odd
    @table.options[:alternate] = :odd
    
    @table.column :name
    actual = @table.build_row('second') do |row, object, index|
      row.cell :name, object
    end
    
    expected = <<-end_eval
<tr class="row alternate">
  <td class="name">second</td>
</tr>
end_eval
    assert_html_equal expected, actual
  end
  
  def test_build_row_with_border_after
    @table.options[:row_border] = :after
    
    @table.column :name
    actual = @table.build_row('first') do |row, object, index|
      row.cell :name, object
    end
    
    expected = <<-end_eval
<tr class="row">
  <td class="name">first</td>
</tr>
<tr><td><div class="horizontal_border"><!-- --></div></td></tr>
end_eval
    assert_html_equal expected, actual
  end
  
  def test_build_last_row_with_no_border_after
    @table.options[:row_border] = :after
    
    @table.column :name
    actual = @table.build_row('third') do |row, object, index|
      row.cell :name, object
    end
    
    expected = <<-end_eval
<tr class="row">
  <td class="name">third</td>
</tr>
end_eval
    assert_html_equal expected, actual
  end
  
  def test_build_row_with_border_before
    @table.options[:row_border] = :before
    
    @table.column :name
    actual = @table.build_row('third') do |row, object, index|
      row.cell :name, object
    end
    
    expected = <<-end_eval
<tr><td><div class="horizontal_border"><!-- --></div></td></tr>
<tr class="row">
  <td class="name">third</td>
</tr>
end_eval
    assert_html_equal expected, actual
  end
  
  def test_build_first_row_with_no_border_before
    @table.options[:row_border] = :before
    
    @table.column :name
    actual = @table.build_row('first') do |row, object, index|
      row.cell :name, object
    end
    
    expected = <<-end_eval
<tr class="row">
  <td class="name">first</td>
</tr>
end_eval
    assert_html_equal expected, actual
  end
  
  def test_build_row_with_missing_cells
    @table.column :name
    @table.column :age
    actual = @table.build_row('first') do |row, object, index|
      row.cell :name, object
    end
    
    expected = <<-end_eval
<tr class="row">
  <td class="name">first</td>
  <td class="age empty"></td>
</tr>
end_eval
    assert_html_equal expected, actual
  end
  
  def test_build_body_empty_collection
    t = CollectionTable.new([])
    t.build_body
    
    expected = <<-end_eval
<tbody>
  <tr class="row">
    <td class="no_content">No matches found.</td>
  </tr>
</tbody>
end_eval
    assert_html_equal expected, t.body
  end
  
  def test_build_empty_collection_but_content_on_empty
    t = CollectionTable.new([], :no_content_on_empty => false)
    t.build_body
    
    expected = <<-end_eval
<tbody>
</tbody>
end_eval
    assert_html_equal expected, t.body
  end
  
  def test_build_body_empty_collection_multiple_columns
    t = CollectionTable.new([])
    t.column :name
    t.column :age
    t.build_body
    
    expected = <<-end_eval
<tbody>
  <tr class="row">
    <td class="no_content" colspan="2">No matches found.</td>
  </tr>
</tbody>
end_eval
    assert_html_equal expected, t.body
  end
  
  def test_build_body_non_empty_collection
    @table.column :name
    @table.build_body do |row, object, index|
      assert_equal @collection[index], object
      
      row.cell :name, object
    end
    
    expected = <<-end_eval
<tbody>
  <tr class="row">
    <td class="name">first</td>
  </tr>
  <tr class="row">
    <td class="name">second</td>
  </tr>
  <tr class="row">
    <td class="name">third</td>
  </tr>
</tbody>
end_eval
    assert_html_equal expected, @table.body
  end
  
  def test_build_body_with_alternate_and_borders
    @table.options[:alternate] = :even
    @table.options[:row_border] = :after
    
    @table.column :name
    @table.build_body do |row, object, index|
      assert_equal @collection[index], object
      
      row.cell :name, object
    end
    
    expected = <<-end_eval
<tbody>
  <tr class="row alternate">
    <td class="name">first</td>
  </tr>
  <tr><td><div class="horizontal_border"><!-- --></div></td></tr>
  <tr class="row">
    <td class="name">second</td>
  </tr>
  <tr><td><div class="horizontal_border"><!-- --></div></td></tr>
  <tr class="row alternate">
    <td class="name">third</td>
  </tr>
</tbody>
end_eval
    assert_html_equal expected, @table.body
  end
  
  def test_build_body_and_dump_table
    @table.column :name
    actual = @table.build_body({}, {}, true) do |row, object, index|
      row.cell :name, object
    end
    
    expected = <<-end_eval
<table cellpadding="0" cellspacing="0">
  <thead>
    <tr class="row header">
      <th class="name" scope="col">Name</th>
    </tr>
  </thead>
  <tbody>
    <tr class="row">
      <td class="name">first</td>
    </tr>
    <tr class="row">
      <td class="name">second</td>
    </tr>
    <tr class="row">
      <td class="name">third</td>
    </tr>
  </tbody>
</table>
end_eval
    assert_html_equal expected, actual
  end
  
  def test_build_footer_with_defaults
    @table.body = ''
    @table.column :name
    actual = @table.build_footer do |row|
      row.cell :name
    end
    
    expected = <<-end_eval
<table cellpadding="0" cellspacing="0">
  <thead>
    <tr class="row header">
      <th class="name" scope="col">Name</th>
    </tr>
  </thead>
  <tfoot>
    <tr class="row footer">
      <td class="name">Name</td>
    </tr>
  </tfoot>
</table>
end_eval
    assert_html_equal expected, actual
  end
  
  def test_build_header_with_no_rows_and_content_on_empty
    t = CollectionTable.new([], :no_content_on_empty => false)
    t.body = ''
    t.column :name
    
    actual = t.build_footer do |row|
      row.cell :name
    end
    
    expected = <<-end_eval
<table cellpadding="0" cellspacing="0">
  <thead>
    <tr class="row header">
      <th class="name" scope="col">Name</th>
    </tr>
  </thead>
  <tfoot>
    <tr class="row footer">
      <td class="name">Name</td>
    </tr>
  </tfoot>
</table>
end_eval
    assert_html_equal expected, actual
  end
  
  def test_build_header_with_no_rows_and_no_content_on_empty
    t = CollectionTable.new([], :no_content_on_empty => true)
    t.body = ''
    t.column :name
    
    actual = t.build_footer do |row|
      row.cell :name
    end
    
    expected = <<-end_eval
<table cellpadding="0" cellspacing="0">
  <thead style="display: none;">
    <tr class="row header">
      <th class="name" scope="col">Name</th>
    </tr>
  </thead>
  <tfoot style="display: none;">
    <tr class="row footer">
      <td class="name">Name</td>
    </tr>
  </tfoot>
</table>
end_eval
    assert_html_equal expected, actual
  end
  
  def test_build_header_with_multiple_columns
    @table.body = ''
    @table.column :name
    @table.column :age
    
    actual = @table.build_footer do |row|
      row.cell :name
      row.cell :age, '21'
    end
    
    expected = <<-end_eval
<table cellpadding="0" cellspacing="0">
  <thead>
    <tr class="row header">
      <th class="name" scope="col">Name</th>
      <th class="age" scope="col">Age</th>
    </tr>
  </thead>
  <tfoot>
    <tr class="row footer">
      <td class="name">Name</td>
      <td class="age">21</td>
    </tr>
  </tfoot>
</table>
end_eval
    assert_html_equal expected, actual
  end
  
  def test_build_header_with_html_options
    @table.body = ''
    @table.column :name
    actual = @table.build_footer(:bgcolor => 'red') do |row|
      row.cell :name
    end
    
    expected = <<-end_eval
<table cellpadding="0" cellspacing="0">
  <thead>
    <tr class="row header">
      <th class="name" scope="col">Name</th>
    </tr>
  </thead>
  <tfoot>
    <tr bgcolor="red" class="row footer">
      <td class="name">Name</td>
    </tr>
  </tfoot>
</table>
end_eval
    assert_html_equal expected, actual
  end
  
  private
  def assert_html_equal(expected, actual)
    assert_equal expected.gsub(/\n\s*/, ''), actual
  end
end
