#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Plaby

  class Writer
    def initialize(fetcher)
      fetcher.each_post.each do |post|
        puts post.filename
      end
    end

    def write(post)
      pp post
      exit
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

