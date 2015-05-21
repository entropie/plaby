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
      def template_data; self; end

      def template
        File.readlines(Plaby::T(template_file)).join
      end

      def to_html
        html = Haml::Engine.new(template).render
        Mustache.render(html, template_data)
      end
    end

    module Template
      def template_file; "plaby.haml"; end
      def template_data; self.content; end
    end

    module Entry
      def template_file; "post.haml"; end
    end

    module Blogroll
      def template_file; "bloglinks.haml"; end
    end
  end


  class Writer

    attr_reader :blogs, :content


    def initialize(blogs, &blk)
      @blogs = blogs
      clear!
      chain(&blk) if block_given?
      self
    end

    def clear!
      @content = {  }
      [:title, :subtitle].each do |key|
        @content[key] = Plaby::config[key]
      end
      @content
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
    end

    def make_blogroll
      str = Writers.with(@blogs, :blogroll).to_html
    rescue Errno::ENOENT
      str = ""
      # templates should be very dynamic and basicially easy to use (and
      # extendable if you feel the need to). There is no need to have
      # a bloglinks file if you dont want the blog roll. So we quietly
      # remove the placeholder if there is no file.
    ensure
      @content[:blogroll] = str
    end

    def chain(&blk)
      clear!
      pp @content
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
