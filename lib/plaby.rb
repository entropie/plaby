#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "bundler"
require "yaml"
require "pp"
require "time"
require "open-uri"
require "fileutils"

Bundler.require

def debug(str)
  $stderr.print "D> "
  $stderr.puts(str)
end

module Plaby

  VERSION = [0, 0, 1]

  Source  = File.expand_path(File.join(File.dirname(__FILE__), ".."))

  Posts   = File.join(Source, "planet")

  PostFormat = "%Y/%m/%d/(identifier)/%H%M-(title).html"

  DefaultConfig = "~/.plaby.yaml"

  HTDOCS = "htdocs"


  TEMPLATE = File.join(Source, "template")
  DEFAULT_TEMPLATE = "default"

  NumbersOfPosts = 20


  def self.T(*frags)
    File.join(TEMPLATE, DEFAULT_TEMPLATE, *frags)
  end

  def self.config
    @config || DefaultConfig
  end

  def self.htdocs_path
    @htdocs_path
  end

  def self.setup
    # create directories
    [htdocs_path,'css','images'].each do |dir|
      begin
        Dir.mkdir(htdocs_path + "/" + dir)
      rescue
      end
    end
    # copy files
    %W'images/de.png images/en.png'.each do |file|
      source = "#{TEMPLATE}/#{DEFAULT_TEMPLATE}/#{file}"
      FileUtils.cp(source, "#{htdocs_path}/#{file}", :verbose => $debug)
    end
  end


  %W'config fetcher writer'.each do |cfg|
    require "#{Source}/lib/plaby/#{cfg}"
  end

  @config = Config.new(config)
  @htdocs_path =  @config[:htdocs_path] || HTDOCS

  setup

  # TODO: from here on everything is basically a workaround before we
  # introduce a real cli interface. No need now, because we dont have
  # options and stuff
  f = Fetcher.read(@config[:blogs]).fetch!
  str = Writer.new(f) { |w|
    w.make_digest
    w.make_blogroll
  }.to_html


  File.open(File.join(@htdocs_path,"index.html"), "w+") do |fp| fp.puts(str) end
  system "cd #{Source} && sass template/default/screen.sass > #{@htdocs_path}/css/screen.css"

end




=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
