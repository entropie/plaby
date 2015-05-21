#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Plaby

  module Writers

    def self.with(obj, const)
      obj.extend(TemplateFile).extend(self[const])
    end

    def self.[](const)
      const_get(const.to_s.capitalize)
    end


    module TemplateFile
      def template
        File.readlines(Plaby::T(template_file)).join
      end
    end

    module Entry

      def template_file; "post.haml"; end

      def to_html
        tmp = Haml::Engine.new(template).render
        Mustache.render(tmp, self)
      end
    end

    module Blogroll

      def template_file; "bloglinks.haml"; end

      def to_html
        tmp = Mustache.render(template, self)
        Haml::Engine.new(tmp).render
      end
    end
  end


  class Writer

    attr_reader :blogs


    def initialize(blogs)
      @blogs, @html = blogs, template
    end

    def template
      @template ||= Haml::Engine.new(File.readlines(Plaby::T("plaby.haml")).join).render
    end

    def write_digest(n = NumbersOfPosts)
      cnt = @blogs.posts.first(n).inject("") do |m, post|
        debug "Post: %s" % post.url
        m << write(post)
      end
      @html = @html.dup.gsub(/%%%%CONTENT%%%%/, cnt)
    end

    def write_bloglinks
      blog_html = Writers.with(@blogs, :blogroll).to_html
      @html = @html.dup.gsub(/%%%%BLOGLINKS%%%%/, blog_html)
    end

    def write(post)
      Writers.with(post, :entry).to_html
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
