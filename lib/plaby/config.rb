#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Plaby

  class Config

    attr_reader :path
    attr_accessor :config

    Defaults = {
      domain: "foo.bar",
      site_title: "y mam",
      header: "Planet Dogs",
      subheader: "batz",
      htdocs_path: 'htdocs',
      template: "default",
      blogs: {
        "hundeprofil" => {
          :url => "http://hundeprofil.de/feed/",
          :image => "http://www.eva.mpg.de/psycho/staff/marie_nitzschner/images/marie_nitzschner.jpg",
          :lang  => "de",
        },
        "dogzombi" => {
          url: "http://dogzombie.blogspot.com/feeds/posts/default?alt=rss",
          image: "http://1.bp.blogspot.com/-HQzigzfFDB0/VU5To4ltG4I/AAAAAAAAATU/X_NbmK2oF2c/s1600/german-shepherd-232393_1280.jpg",
          lang: "en"
        },
        "verhalten" => {
          url: "https://verhalten.wordpress.com/feed/",
          image: "https://pbs.twimg.com/profile_images/3077490747/ef34459f9c4ec742a28ffcdff6aec938.jpeg",
          lang: "de",
          description: "Behavior Analyst; Skeptic; Blog Verhalten usw. verhalten.wordpress.com on Behavior Analysis and related topics",
          twitter: "broede"
        },
        "dalmi_blog" => {
          url: "http://www.dalmi-blog.de/feed/",
          image: "http://www.dalmi-blog.de/wp-content/uploads/2014/10/2014-10-04-herbstdummy-03klein-400x271.jpg",
          lang: "de"
        },
        "cavecani" => {
          :url => "http://cavecani.de/wissenswertes/feed/",
          :image => "http://cavecani.de/wp-content/themes/CaveCani_html5Boilerplate/images/header_logo.png",
          :lang  => "de"
        }
      }
    }

    def initialize(path)
      @path = File.expand_path(path)
      @config = {  }
      load
    end

    def [](obj)
      @config[obj]
    end

    def create_or_update(opt = {  }, force = false)
      load!
    end

    def load
      raise Errno::ENOENT unless File.exist?(path)
      @config.merge! YAML::load_file(path)
    rescue Errno::ENOENT
      write
    end

    def write(hsh = Defaults)
      @config.merge!(hsh)
      File.open(path, "w+") { |fp| fp.write(@config.to_yaml) }
      debug "wrote initial config file to #{path}"
    end

    def inspect
      %Q'#{path}: #{PP.pp(super, '')}'
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
