#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "bundler"
require "yaml"
require "pp"
require "time"
require "open-uri"

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

  HTDOCS = "~/public_html/plaby"


  TEMPLATE = File.join(Source, "template")
  DEFAULT_TEMPLATE = "default"

  NumbersOfPosts = 20


  def self.T(*frags)
    File.join(TEMPLATE, DEFAULT_TEMPLATE, *frags)
  end

  def self.config
    @config || DefaultConfig
  end

  %W'config fetcher writer'.each do |cfg|
    require "#{Source}/lib/plaby/#{cfg}"
  end

  @config = Config.new(config)

  # TODO: from here on everything is basically a workaround before we
  # introduce a real cli interface. No need now, because we dont have
  # options and stuff
  f = Fetcher.read(@config[:blogs]).fetch!
  str = Writer.new(f) { |w|
    w.write_digest
    w.write_bloglinks
  }.to_html

  File.open(File.join(Source, "htdocs", "index.html"), "w+") do |fp| fp.puts(str) end
  system "cd #{Source} && sass template/default/screen.sass > htdocs/css/screen.css"

end




=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
