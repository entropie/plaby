
#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Plaby

  class Blog

    attr_reader :identifier, :values

    attr_accessor :entries

    NumbersOfPosts = 10

    def initialize(ident, values)
      @identifier = ident
      @values = values
    end

    def url
      @values[:url]
    end

    def read(limit = NumbersOfPosts)
      @entries = Entries.new
      Feedjira::Feed.fetch_and_parse(url).entries.each do |a|
        @entries << Entry.new(self, a)
      end
    end

    def inspect
      "#{@identifier}: #{@entries.size}"
    end


    class Entries < Array
    end

    class Entry
      def initialize(blog, hsh)
        @blog = blog
        @values = hsh
      end

      def url
        @values["url"]
      end

      def method_missing(*m)
        @values.send(*m)
      end

      def published
        @values.published.to_time
      end

      def date
        @values.published.to_time
      end

      def filename
        @filename ||= date.strftime(PostFormat).
          gsub(/\(identifier\)/, @blog.identifier).
          gsub(/\(title\)/, @values.title.downcase).
          gsub(/\?/, '').
          gsub(/\:/, '').
          gsub(/\;/, '').
          gsub(/\,/, '').
          gsub(/„/, '').
          gsub(/“/, '').
          gsub(/[äöüÖÄÜ]/, '').
          gsub(/\!/, '').
          gsub(/\(/, '').
          gsub(/'/, '').
          gsub(/\)/, '').
          slug!
      end
    end
  end

  class Blogs < Array
    def [](obj)
      obj = obj.to_s
      select{ |c| c.identifier == obj}.first
    end

    def all_posts
      posts = []
      each do |c|
        posts.push(*c.entries)
      end
      posts.sort_by{ |post| post.date }.reverse
    end


    def posts
      @posts ||= all_posts
    end
  end

  module Fetcher

    def blogs
      @@blogs
    end
    module_function :blogs

    def self.read(blogs)
      @@blogs = Blogs.new
      blogs.each_pair { |ident, values|
        @@blogs << Blog.new(ident, values)
      }
      self
    end

    def self.fetch!
      blogs.each do |b|
        b.read()
      end
    end

    def self.to_a
      @@blogs
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
