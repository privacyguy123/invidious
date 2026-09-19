require "html"
require "uri"

module Invidious::Videos::Title
  def self.to_html(title : String) : String
    String.build do |html|
      offset = 0
      title.scan(/(?:\A|[\s\p{Z}\p{Ps}\p{Pi}"'])#([\p{L}\p{N}_][\p{L}\p{M}\p{N}_]*)/) do |match|
        start = match.byte_begin(1) - 1
        html << HTML.escape(title.byte_slice(offset, start - offset))
        html << %(<a href="/hashtag/#{URI.encode_path_segment(match[1])}">)
        html << HTML.escape("##{match[1]}") << "</a>"
        offset = match.byte_end(1)
      end
      html << HTML.escape(title.byte_slice(offset))
    end
  end
end
