#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Plaby

  class Config

    attr_reader :path
    attr_accessor :config

    Defaults = {
      :planet => "Planet Dogs",
      :bum => "batz",
      :htdocs_path => 'htdocs',
      :blogs => {
        "hundeprofil" => {
          :url => "http://hundeprofil.de/feed/",
          :image => "http://www.eva.mpg.de/psycho/staff/marie_nitzschner/images/marie_nitzschner.jpg",
          :lang  => "de"
        },
        "dogzombi" => {
          :url => "http://dogzombie.blogspot.com/feeds/posts/default?alt=rss",
          :image => "http://1.bp.blogspot.com/-HQzigzfFDB0/VU5To4ltG4I/AAAAAAAAATU/X_NbmK2oF2c/s1600/german-shepherd-232393_1280.jpg",
          :lang  => "en"
        },
        "lumpi4" => {
          :url => "http://www.lumpi4.de/feed/",
          :image => "http://www.lumpi4.de/wp-content/uploads/2013/07/kolumne.jpg",
          :lang  => "de"
        },
        "verhalten" => {
          :url => "https://verhalten.wordpress.com/feed/",
          :image => "https://verhalten.files.wordpress.com/2013/01/cropped-labwork2.jpg",
          :lang  => "de"
        },
        "Dalmi Blog" => {
          url: "http://www.dalmi-blog.de/feed/",
          image: "http://www.dalmi-blog.de/wp-content/uploads/2014/10/2014-10-04-herbstdummy-03klein-400x271.jpg",
          lang: "de"
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
