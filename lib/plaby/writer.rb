#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Plaby

  module EntryWriter

    def to_html
      str = "<div class=\"entry\"><h2><a href=\"#{ url }\">#{title}</a></h2>"
      str << "<div class=\"date\">#{published}</div>"
      cont = TidyFFI::Tidy.with_options(:show_body_only => 1).new(summary).clean
      str << "<div class=\"content\">" << cont << "</div></div>"
      str
    end
  end

  class Writer

    Template = File.join(Source, "src", "plaby.html")

    attr_reader :blogs

    def initialize(blogs)
      @blogs = blogs
      # fetcher.each_post.each do |post|
      #   puts post.filename
      # end
    end

    def template
      @template ||= File.readlines(Template).join
    end

    def write_digest(n = 10)
      cnt = ""
      @blogs.posts.first(n).each do |post|
        cnt << write(post)
        cnt << "\n"
      end

      newfile = template.gsub(/%%%%CONTENT%%%%/, cnt)

      puts newfile
    end

    def write(post)
      post.extend(EntryWriter).to_html
    end
  end

end

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end

