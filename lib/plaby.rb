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
  return nil unless Plaby.debug
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

  NumbersOfPosts = 30

  def self.debug=(obj)
    @debug = obj
  end

  def self.debug
    @debug || false
  end

  def self.T(*frags)
    File.join(TEMPLATE, template, *frags)
  end

  def self.config
    @config || DefaultConfig
  end

  def self.htdocs_path
    @htdocs_path
  end

  def self.template
    ENV["TEMPLATE"] || config[:template] || DEFAULT_TEMPLATE
  end

  def self.setup
    [:css, :javascript, :images, :feed].map(&:to_s).each do |m|
      FileUtils.mkdir_p(File.join(File.join(Source, htdocs_path, m)), :verbose => self.debug)
      Dir.glob(File.join(TEMPLATE, template, m) + "/*.*").each do |f|
        target = File.join(htdocs_path, m, File.basename(f))
        unless File.exist?(target)
          FileUtils.cp(f, target, :verbose => self.debug)
        end
      end
    end

  end


  self.debug = true


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

    w.write_feed
  }.to_html


  File.open(File.join(@htdocs_path,"index.html"), "w+") do |fp| fp.puts(str) end
  system "cd #{Source} && sass #{TEMPLATE}/#{template}/screen.sass > #{@htdocs_path}/css/screen.css"

end




=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
