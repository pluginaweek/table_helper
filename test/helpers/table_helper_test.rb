require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class TableHelperTest < ActionView::TestCase
  tests TableHelper
  
  def test_should_build_collection_table
    html = collection_table(['first', 'second', 'last']) do |header, body|
      header.column :title
      
      body.build do |row, post_title, index|
        row.title post_title
      end
    end
    
    expected = <<-end_str
      <table cellpadding="0" cellspacing="0">
        <thead>
          <tr>
            <th class="title" scope="col">Title</th>
          </tr>
        </thead>
        <tbody>
          <tr class="row">
            <td class="title">first</td>
          </tr>
          <tr class="row">
            <td class="title">second</td>
          </tr>
          <tr class="row">
            <td class="title">last</td>
          </tr>
        </tbody>
      </table>
    end_str
    assert_html_equal expected, html
  end
end
