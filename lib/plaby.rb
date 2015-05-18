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

  require "#{Source}/lib/plaby/config"
  require "#{Source}/lib/plaby/fetcher"
  require "#{Source}/lib/plaby/writer"

  def self.config
    @config || DefaultConfig
  end

  @config = Config.new(config)

  f = Fetcher.read(@config[:blogs]).fetch!
  Writer.new(f)
end




=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
