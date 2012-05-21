require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class TableHelperTest < ActionView::TestCase
  class << Rails
    undef application # Avoid silly Rails bug: https://github.com/rails/rails/pull/6429
  end

  tests TableHelper

  class Post
  end

  def test_should_build_collection_table
    html = collection_table(['first', 'second', 'last'], Post) do |t|
      t.header :title
      t.rows.each do |row, post_title, index|
        row.title post_title
      end
      t.footer :total, t.collection.length
    end

    expected = <<-end_str
      <table cellpadding="0" cellspacing="0" class="posts ui-collection">
        <thead>
          <tr>
            <th class="post-title" scope="col">Title</th>
          </tr>
        </thead>
        <tbody>
          <tr class="post ui-collection-result">
            <td class="post-title">first</td>
          </tr>
          <tr class="post ui-collection-result">
            <td class="post-title">second</td>
          </tr>
          <tr class="post ui-collection-result">
            <td class="post-title">last</td>
          </tr>
        </tbody>
        <tfoot>
          <tr>
            <td class="post-total">3</td>
          </tr>
        </tfoot>
      </table>
    end_str
    assert_html_equal expected, html
  end

  def test_should_be_html_safe_in_rails_3
    html = collection_table(['<a&b>', '<b>ok!</b>'.html_safe], Post) do |t|
      t.header :title
      t.rows.each do |row, post_title, index|
        row.title post_title
      end
      t.footer :total, '<c&d>'
      t.footer :grand_total, '<b>ok too!</b>'.html_safe
    end

    assert html.html_safe?

    expected = <<-end_str
      <table cellpadding="0" cellspacing="0" class="posts ui-collection">
        <thead>
          <tr>
            <th class="post-title" scope="col">Title</th>
          </tr>
        </thead>
        <tbody>
          <tr class="post ui-collection-result">
            <td class="post-title">&lt;a&amp;b&gt;</td>
          </tr>
          <tr class="post ui-collection-result">
            <td class="post-title"><b>ok!</b></td>
          </tr>
        </tbody>
        <tfoot>
          <tr>
            <td class="post-total">&lt;c&amp;d&gt;</td>
            <td class="post-grand_total"><b>ok too!</b></td>
          </tr>
        </tfoot>
      </table>
    end_str
    assert_html_equal expected, html
  end if "".respond_to?(:html_safe?)
end
