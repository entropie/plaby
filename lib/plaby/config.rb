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
          :image => "https://kynologisch.net/wp-content/uploads/2015/05/marie-offiziell-300x300.jpg",
          :lang  => "de",
        },
        "verhalten" => {
          url: "https://verhalten.wordpress.com/feed/",
          image: "https://secure.gravatar.com/avatar/67a17dc80e08cbf0b080cce4a5b7cc94",
          lang: "de",
          twitter: "broede"
        },
        "fluffology" => {
          url: "http://xeno:2308/feed/",
          image: "https://farm2.staticflickr.com/1825/29344213768_c21f4e9f03_z.jpg",
          lang: "de",
          twitter: "fluffology"
        },
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
