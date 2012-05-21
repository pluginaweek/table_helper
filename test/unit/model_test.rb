ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:",
)
ActiveRecord::Migration.suppress_messages do
  ActiveRecord::Schema.define(:version => 666) do
    create_table "people", :force => true do |t|
      t.string   "first_name"
      t.string   "last_name"
    end
  end
end

class Person < ActiveRecord::Base
  create(:first_name => 'John', :last_name => 'Smith')
end

class HeaderWithModelsTest < ActiveRecord::TestCase
  def test_should_include_all_columns_if_not_selecting_columns
    table = TableHelper::CollectionTable.new(Person.all)
    @header = TableHelper::Header.new(table)
    assert_equal %w(first_name id last_name), @header.column_names.sort
  end

  def test_should_only_include_selected_columns_if_specified_in_query
    table = TableHelper::CollectionTable.new(Person.all(:select => 'first_name'))
    @header = TableHelper::Header.new(table)
    assert_equal %w(first_name), @header.column_names.sort
  end
end
