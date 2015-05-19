#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Plaby

  module EntryWriter

    def template
      File.readlines(File.join(TEMPLATE, DEFAULT_TEMPLATE, "post.haml")).join
    end

    def to_html
      tmp = Haml::Engine.new(template).render
      Mustache.render(tmp, self)
    end
  end

  class Writer

    Template = File.join(Source, "src", "plaby.html")

    attr_reader :blogs

    def initialize(blogs)
      @blogs = blogs
    end

    def template
      @template ||= File.readlines(Template).join
    end

    def write_digest(n = NumbersOfPosts)
      cnt = ""
      @blogs.posts.first(n).each do |post|
        cnt << write(post)
        cnt << "\n"
      end
      template.gsub(/%%%%CONTENT%%%%/, cnt)
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

