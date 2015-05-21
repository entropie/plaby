#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Plaby

  module EntryWriter

    def template
      File.readlines(Plaby::T("post.haml")).join
    end

    def to_html
      tmp = Haml::Engine.new(template).render
      Mustache.render(tmp, self)
    end
  end

  module BlogLinkWriter

    def template
      File.readlines(Plaby::T("bloglinks.haml")).join
    end

    def to_html
      tmp = Mustache.render(template,self)
      Haml::Engine.new(tmp).render
    end
  end

  class Writer

    attr_reader :blogs


    def initialize(blogs)
      @blogs = blogs
      @html = template
    end

    def template
      @template ||= Haml::Engine.new(File.readlines(Plaby::T("plaby.haml")).join).render
    end

    def write_digest(n = NumbersOfPosts)
      cnt = @blogs.posts.first(n).inject("") do |m, post|
        puts post.url
        m << write(post)
      end
      @html = @html.dup.gsub(/%%%%CONTENT%%%%/, cnt)
    end

    def write_bloglinks
      blog_html = @blogs.extend(BlogLinkWriter).to_html
      @html = @html.dup.gsub(/%%%%BLOGLINKS%%%%/,blog_html)
    end

    def write(post)
      post.extend(EntryWriter).to_html
    end

    def to_html
      @html
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
