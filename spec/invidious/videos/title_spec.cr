require "spectator"
require "../../../src/invidious/videos/title"

Spectator.describe Invidious::Videos::Title do
  it "links hashtags at the start, middle and end of a title" do
    expect(described_class.to_html("#First with #TwoWords and #last")).to eq(
      %(<a href="/hashtag/First">#First</a> with <a href="/hashtag/TwoWords">#TwoWords</a> and <a href="/hashtag/last">#last</a>)
    )
  end

  it "keeps punctuation outside hashtag links" do
    expect(described_class.to_html(%((#one), [#two]! "#three"))).to eq(
      %((<a href="/hashtag/one">#one</a>), [<a href="/hashtag/two">#two</a>]! &quot;<a href="/hashtag/three">#three</a>&quot;)
    )
  end

  it "preserves Unicode letters, combining marks, numbers and underscores" do
    expect(described_class.to_html("🎵 #cafe\u0301 #東京 #हिन्दी #2026_live")).to eq(
      %(🎵 <a href="/hashtag/cafe%CC%81">#cafe\u0301</a> <a href="/hashtag/%E6%9D%B1%E4%BA%AC">#東京</a> <a href="/hashtag/%E0%A4%B9%E0%A4%BF%E0%A4%A8%E0%A5%8D%E0%A4%A6%E0%A5%80">#हिन्दी</a> <a href="/hashtag/2026_live">#2026_live</a>)
    )
  end

  it "recognizes tabs, newlines and non-breaking spaces as boundaries" do
    expect(described_class.to_html("a\t#one\n#two\u00a0#three")).to eq(
      %(a\t<a href="/hashtag/one">#one</a>\n<a href="/hashtag/two">#two</a>\u00a0<a href="/hashtag/three">#three</a>)
    )
  end

  it "recognizes Unicode opening brackets and quotation marks" do
    expect(described_class.to_html("「#東京」 ‘#music’")).to eq(
      %(「<a href="/hashtag/%E6%9D%B1%E4%BA%AC">#東京</a>」 ‘<a href="/hashtag/music">#music</a>’)
    )
  end

  it "does not link fragments, suffixes, bare hashes or adjacent hashes" do
    title = "https://example.com/#fragment file#part C# ##tag # #\u0301"
    expect(described_class.to_html(title)).to eq(HTML.escape(title))
  end

  it "escapes markup and entities without creating extra elements" do
    expect(described_class.to_html(%(<script>alert("x")</script> & #safe <img src=x> &#123;))).to eq(
      %(&lt;script&gt;alert(&quot;x&quot;)&lt;/script&gt; &amp; <a href="/hashtag/safe">#safe</a> &lt;img src=x&gt; &amp;#123;)
    )
  end

  it "preserves empty and ordinary titles" do
    expect(described_class.to_html("")).to eq("")
    expect(described_class.to_html("Rock & roll")).to eq("Rock &amp; roll")
  end
end
