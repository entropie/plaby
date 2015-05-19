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

  require "#{Source}/lib/plaby/config"
  require "#{Source}/lib/plaby/fetcher"
  require "#{Source}/lib/plaby/writer"

  def self.config
    @config || DefaultConfig
  end

  @config = Config.new(config)

  f = Fetcher.read(@config[:blogs]).fetch!
  str = Writer.new(f).write_digest

  File.open(File.join(Source, "htdocs", "index.html"), "w+") do |fp| fp.puts(str) end
  system "cd #{Source} && sass src/screen.sass > htdocs/css/screen.css"
end




=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
