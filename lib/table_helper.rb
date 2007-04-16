require 'set_or_append'
require 'table_helper/collection_table'

module PluginAWeek #:nodoc:
  module Helpers #:nodoc:
    # Provides a set of methods for turning a collection into a table.  The
    # following is an example of a table that lists a series of attributes for
    # each Post in a collection of posts.
    # 
    #  <%
    #    collection_table(@posts, {}, :id => 'posts', :class => 'summary') do |header, body|
    #      header.column :title
    #      header.column :category
    #      header.column :author
    #      header.column :publish_date, 'Date<br \>Published'
    #      header.column :num_comments, '# Comments'
    #      header.column :num_trackbacks, '# Trackbacks'
    #      
    #      body.alternate = true
    #      body.build do |row, post, index|
    #        row.category       post.category.name
    #        row.author         post.author.name
    #        row.publish_date   time_ago_in_words(post.published_on)
    #        row.num_comments   post.comments.empty? ? '-' : post.comments.size
    #        row.num_trackbacks post.trackbacks.empty? ? '-' : post.trackbacks.size
    #      end
    #    end
    #  %>
    # 
    # ...is compiled to (formatted here for the sake of sanity):
    # 
    #  <table cellpadding="0" cellspacing="0" class="summary" id="posts">
    #  <thead>
    #    <tr>
    #      <th class="title" scope="col">Title</th>
    #      <th class="category" scope="col">Category</th>
    #      <th class="author" scope="col">Author</th>
    #      <th class="publish_date" scope="col">Date<br \>Published</th>
    #      <th class="num_comments" scope="col"># Comments</th>
    #      <th class="num_trackbacks" scope="col"># Trackbacks</th>
    #    </tr>
    #  </thead>
    #  <tbody class="alternate">
    #    <tr class="row">
    #      <td class="title">Open-source projects: The good, the bad, and the ugly</td>
    #      <td class="category">General</td>
    #      <td class="author">John Doe</td>
    #      <td class="publish_date">23 days</td>
    #      <td class="num_comments">-</td>
    #      <td class="num_trackbacks">-</td>
    #    </tr>
    #    <tr class="row alternate">
    #      <td class="title">5 reasons you should care about Rails</td>
    #      <td class="category">Rails</td><td class="author">John Q. Public</td>
    #      <td class="publish_date">21 days</td>
    #      <td class="num_comments">-</td>
    #      <td class="num_trackbacks">-</td>
    #    </tr>
    #    <tr class="row">
    #      <td class="title">Deprecation: Stop digging yourself a hole</td>
    #      <td class="category">Rails</td>
    #      <td class="author">Jane Doe</td>
    #      <td class="publish_date">17 days</td>
    #      <td class="num_comments">-</td>
    #      <td class="num_trackbacks">-</td>
    #    </tr>
    #    <tr class="row alternate">
    #      <td class="title">Jumpstart your Rails career at RailsConf 2007</td>
    #      <td class="category">Conferences</td>
    #      <td class="author">Jane Doe</td>
    #      <td class="publish_date">4 days</td>
    #      <td class="num_comments">-</td>
    #      <td class="num_trackbacks">-</td>
    #    </tr>
    #    <tr class="row">
    #      <td class="title">Getting some REST</td>
    #      <td class="category">Rails</td>
    #      <td class="author">John Doe</td>
    #      <td class="publish_date">about 18 hours</td>
    #      <td class="num_comments">-</td>
    #      <td class="num_trackbacks">-</td>
    #    </tr>
    #  </tbody>
    #  </table>
    # 
    # == Creating footers
    # 
    # Footers allow you to show some sort of summary information based on the
    # data displayed in the body of the table.  Below is an example:
    # 
    #  <%
    #    collection_table(@posts, :footer => true) do |header, body, footer|
    #      header.column :title
    #      header.column :category
    #      header.column :author
    #      header.column :publish_date, 'Date<br \>Published'
    #      header.column :num_comments, '# Comments'
    #      header.column :num_trackbacks, '# Trackbacks'
    #      
    #      body.alternate = true
    #      body.build do |row, post, index|
    #        row.category       post.category.name
    #        row.author         post.author.name
    #        row.publish_date   time_ago_in_words(post.published_on)
    #        row.num_comments   post.comments.empty? ? '-' : post.comments.size
    #        row.num_trackbacks post.trackbacks.empty? ? '-' : post.trackbacks.size
    #      end
    #      
    #      footer.cell :num_comments, @posts.inject(0) {|sum, post| sum += post.comments.size}
    #      footer.cell :num_trackbacks, @posts.inject(0) {|sum, post| sum += post.trackbacks.size}
    #    end
    #  %>
    module TableHelper
      # Creates a new table based on the given collection
      # 
      # Configuration options:
      # 
      # <tt>class</tt> - Specify the type of objects expected in the collection if it can't be guessed from its contents.
      # <tt>header</tt> - Specify if a header (thead) should be built into the table.  Default is true.
      # <tt>footer</tt> - Specify if a footer (tfoot) should be built into the table.  Default is false.
      def collection_table(collection, options = {}, html_options = {}, &block)
        table = CollectionTable.new(collection, options, html_options)
        table.build(&block)
        table.html
      end
    end
  end
end

ActionController::Base.class_eval do
  helper PluginAWeek::Helpers::TableHelper
end
