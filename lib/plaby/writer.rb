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

    module Template

      def template_file; "plaby.haml"; end

      def to_html
        tmp = Haml::Engine.new(template).render
        Mustache.render(tmp, self.content)
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

    attr_reader :blogs, :content


    def initialize(blogs, &blk)
      @blogs = blogs
      @content = {  }
      chain(&blk) if block_given?
      self
    end

    def clear!
      @content = {  }
    end

    def template
      @template ||= Haml::Engine.new(File.readlines(Plaby::T("plaby.haml")).join).render
    end

    def make_digest(n = NumbersOfPosts)
      cnt = @blogs.posts.first(n).inject("") do |m, post|
        debug "Post: %s" % post.url
        m << write(post)
      end
      @content[:posts] = cnt
      # @html.gsub!(/%%%%CONTENT%%%%/, cnt)
    end

    def make_blogroll
      str = ""
      str = Writers.with(@blogs, :blogroll).to_html
      # @html.gsub!(/%%%%BLOGLINKS%%%%/, blog_html)
    rescue Errno::ENOENT
      # templates should be very dynamic and basicially easy to use (and
      # extendable if you feel the need to). There is no need to have
      # a bloglinks file if you dont want the blog roll. So we quietly
      # remove the placeholder if there is no file.
    ensure
      @content[:blogroll] = str
    end

    def chain(&blk)
      clear!
      yield self
      self
    end

    def write(post)
      Writers.with(post, :entry).to_html
    end

    def to_html
      Writers.with(self, :template).to_html
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
