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

  HTDOCS = "htdocs"


  TEMPLATE = File.join(Source, "template")
  DEFAULT_TEMPLATE = "default"

  NumbersOfPosts = 20


  def self.T(file)
    File.join(TEMPLATE, DEFAULT_TEMPLATE, file)
  end

  def self.config
    @config || DefaultConfig
  end

  %W'config fetcher writer'.each do |cfg|
    require "#{Source}/lib/plaby/#{cfg}"
  end

  @config = Config.new(config)

  @htdocs_path = @config.config.has_key?(:htdocs_path) ? @config[:htdocs_path] : HTDOCS


  # TODO: from here on
  f = Fetcher.read(@config[:blogs]).fetch!
  writer = Writer.new(f)
  writer.write_digest
  writer.write_bloglinks
  str = writer.to_html

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
