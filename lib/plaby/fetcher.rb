
#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Plaby

  module Escaper
    def self.unescape_xml(input)
      input.gsub(/&(#([0-9]{2,4})|#[xX]([0-9a-fA-F]{2,4})|quot|apos|lt|gt|amp);/) do |s|
        case s
        when '&quot;';  '"'       # replace &quot; with "
        when '&apos;';  "'"       # replace &apos; with '
        when '&lt;'  ;  '<'       # replace &lt;   with <
        when '&gt;'  ;  '>'       # replace &gt;   with >
        when '&amp;' ;  '&'       # replace &amp;  with &
        else
          # convert unicode code point (decimal or hexadecimal) to a char
          hexa_flag = $1.start_with?('#x')
          unicode_number = hexa_flag ? $3.to_i(16) : $2.to_i
          unicode_number.chr(Encoding::UTF_8)
        end
      end
    end
  end


  class Blog

    attr_reader :identifier, :values, :title, :link, :description

    attr_accessor :entries

    def initialize(ident, values)
      @identifier = ident
      @values = values
    end

    def url
      @values[:url]
    end

    def image
      if get_image
        return image_path
      else
        "images/blog-placeholder.jpg"
      end
    end

    def read
      @entries = Entries.new

      xml = HTTParty.get(url).body
      feed =  Feedjira.parse(xml)

      debug "  read> %s (%s)" % [feed.title, feed.url]

      feed.entries.each do |a|
        read_entry = Entry.new(self, a)
        debug "    post> entry: %s" % [read_entry.title]
        @entries << read_entry
      end
      @title = Escaper.unescape_xml(feed.title)
      @link = feed.url
      @description = feed.description
    end

    def config
      Plaby.config[:blogs][@identifier]
    end

    def language
      config[:lang]
    end

    def image_path
      title_slug = @identifier.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
      "images/blog-avatar-#{title_slug}.jpg"
    end

    def get_image
      local_image_path = File.join(Plaby.htdocs_path, image_path)
      # first try local copy
      if File.exist?(local_image_path)
        open(local_image_path).read
      else

        image_file = open(@values[:image]).read
        open(local_image_path, "w+") do |f|
          f.write(image_file)
        end
        image_file
      end
    rescue # also no local image
    end


    class Entries < Array
    end

    class Entry
      def initialize(blog, hsh)
        @blog = blog
        @values = hsh
      end

      def blog
        @blog
      end

      def lang
        @blog.language
      end

      def description
        @blog.description
      end

      def author
        @values["author"]
      end

      def author_with_link
        "<a href=\"#{url}\">#{author}</a>"
      end

      def title
        @values["title"]
      end

      def blog_title
        @blog.title
      end

      def url
        @values["url"]
      end

      def method_missing(*m)
        @values.send(*m)
      end

      def summary
        @values["summary"]
      end

      def text
        @values["content"] || summary
      end

      def tags
        @tags ||= (@values["categories"] || []).map{ |t| "<li>#{t}</li>" }.join
      end

      def published
        @values.published.to_time
      end

      def date
        @values.published.to_time.strftime("%A, <strong>%e%b%Y</strong>")
      end
    end
  end

  class Blogs < Array
    def [](obj)
      obj = obj.to_s
      select{ |c| c.identifier == obj}.first
    end

    def all_posts
      posts = inject([]) do |m,c|
        m.push(*c.entries)
      end
      posts.sort_by{ |post| post.date }.reverse
    end

    def blogs
      self
    end

    def posts
      @posts ||= all_posts
    end
  end

  module Fetcher

    def self.blogs=(bs)
      @blogs = bs
    end

    def self.blogs
      @blogs
    end

    def self.read(blogs)
      self.blogs = Blogs.new
      blogs.each_pair { |ident, values|
        self.blogs << Blog.new(ident, values)
      }
      self
    end

    def self.fetch!
      blogs.each do |b|
        b.read
      end
    end

    def self.to_a
      blogs
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
