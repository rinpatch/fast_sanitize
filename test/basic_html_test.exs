defmodule FastSanitize.Sanitizer.BasicHTMLTest do
  use ExUnit.Case

  defp basic_html_sanitize(text) do
    {:ok, text} = FastSanitize.basic_html(text)
    text
  end

  test "strips nothing" do
    input = "This <b>is</b> <b>an</b> <i>example</i> of <u>space</u> eating."
    expected = "This <b>is</b> <b>an</b> <i>example</i> of <u>space</u> eating."
    assert expected == basic_html_sanitize(input)
  end

  test "does strip language class from code tag" do
    input = "<code class=\"ruby\">Something.new</code>"
    expected = "<code>Something.new</code>"
    assert expected == basic_html_sanitize(input)
  end

  test "strips everything except the allowed tags" do
    input = "<h1>hello <script>code!</script></h1>"
    expected = "<h1>hello code!</h1>"
    assert expected == basic_html_sanitize(input)
  end

  test "strips everything except the allowed tags (for multiple tags)" do
    input =
      "<section><header><script>code!</script></header><p>hello <script>code!</script></p></section>"

    expected = "code!<p>hello code!</p>"
    assert expected == basic_html_sanitize(input)
  end

  test "strips everything for faulty allowed_tags: key" do
    input = "<h1>hello<h1>"
    expected = "hello"
    assert expected != basic_html_sanitize(input)
  end

  test "strips invalid html" do
    input = "<<<bad html"
    expected = "&lt;&lt;"
    assert expected == basic_html_sanitize(input)
  end

  test "strips tags with quote" do
    input = "<\" <img src=\"trollface.gif\" onload=\"alert(1)\"> hi"

    assert "&lt;&quot; <img src=\"trollface.gif\"/> hi" ==
             basic_html_sanitize(input)
  end

  test "strips nested tags" do
    input = "Wei<<a>a onclick='alert(document.cookie);'</a>/>rdos"
    expected = "Wei&lt;<a>a onclick=&#39;alert(document.cookie);&#39;</a>/&gt;rdos"
    assert expected == basic_html_sanitize(input)
  end

  test "strips certain tags in multi line strings" do
    input =
      "<title>This is <b>a <a href=\"\" target=\"_blank\">test</a></b>.</title>\n\n<!-- it has a comment -->\n\n<p>It no <b>longer <strong>contains <em>any <strike>HTML</strike></em>.</strong></b></p>\n"

    expected =
      "This is &lt;b&gt;a &lt;a href=&quot;&quot; target=&quot;_blank&quot;&gt;test&lt;/a&gt;&lt;/b&gt;.\n\n\n\n<p>It no <b>longer <strong>contains <em>any HTML</em>.</strong></b></p>\n"

    assert expected == basic_html_sanitize(input)
  end

  test "strips blank string" do
    assert "" == basic_html_sanitize("")
    assert "" == basic_html_sanitize(nil)
  end

  test "strips nothing from plain text" do
    input = "Dont touch me"
    expected = "Dont touch me"
    assert expected == basic_html_sanitize(input)
  end

  test "strips nothing from a sentence" do
    input = "This is a test."
    expected = "This is a test."
    assert expected == basic_html_sanitize(input)
  end

  test "strips tags with comment" do
    input = "This has a <!-- comment --> here."
    expected = "This has a  here."
    assert expected == basic_html_sanitize(input)
  end

  test "strip_tags escapes special characters" do
    assert "&amp;", basic_html_sanitize("&")
  end

  # link sanitizer

  test "test_strip_links_with_tags_in_tags" do
    input = "<<a>a href='hello'>all <b>day</b> long<</A>/a>"
    expected = "&lt;<a>a href=&#39;hello&#39;&gt;all <b>day</b> long&lt;</a>/a&gt;"
    assert expected == basic_html_sanitize(input)
  end

  test "test_strip_links_with_plaintext" do
    assert "Dont touch me" == basic_html_sanitize("Dont touch me")
  end

  @tag href_scrubbing: true
  test "test_strip_links_with_line_feed_and_uppercase_tag" do
    input = "<a href='almost'>on my mind</a> <A href='almost'>all day long</A>"

    assert ~s(<a href="almost">on my mind</a> <a href="almost">all day long</a>) ==
             basic_html_sanitize(input)
  end

  @tag href_scrubbing: true
  test "test_strip_links_leaves_nonlink_tags" do
    assert ~s(<a href="almost">My mind</a>\n<a href="almost">all <b>day</b> long</a>) ==
             basic_html_sanitize(
               "<a href='almost'>My mind</a>\n<A href='almost'>all <b>day</b> long</A>"
             )
  end

  @tag href_scrubbing: true
  test "strips tags with basic_html_sanitize/1" do
    input = "<p>This <u>is</u> a <a href='test.html'><strong>test</strong></a>.</p>"

    assert "<p>This <u>is</u> a <a href=\"test.html\"><strong>test</strong></a>.</p>" ==
             basic_html_sanitize(input)
  end

  @a_href_hacks [
    "<a href=\"javascript:alert('XSS');\">text here</a>",
    "<a href=javascript:alert('XSS')>text here</a>",
    "<a href=javascript:alert(&quot;XSS&quot;)>text here</a>",
    "<a href=javascript:alert(String.fromCharCode(88,83,83))>text here</a>"
  ]

  @tag href_scrubbing: true
  test "strips malicious protocol hacks from a href attribute" do
    expected = "<a>text here</a>"

    Enum.each(@a_href_hacks, fn x ->
      assert expected == basic_html_sanitize(x)
    end)
  end

  @tag href_scrubbing: true
  test "does not strip x03a legitimate" do
    assert "<a href=\"http://legit\"></a>" ==
             basic_html_sanitize("<a href=\"http&#x3a;//legit\">")

    assert "<a href=\"http://legit\"></a>" ==
             basic_html_sanitize("<a href=\"http&#x3A;//legit\">")
  end

  test "test_strip links with links" do
    input =
      "<a href='http://www.elixirstatus.com/'><a href='http://www.elixirstatus.com/' onlclick='steal()'>0wn3d</a></a>"

    assert ~s(<a href="http://www.elixirstatus.com/"></a><a href="http://www.elixirstatus.com/">0wn3d</a>) ==
             basic_html_sanitize(input)
  end

  test "test_strip_links_with_linkception" do
    assert ~s(<a href="http://www.elixirstatus.com/">Mag</a><a href="http://www.elixir-lang.org/">ic</a>) ==
             basic_html_sanitize(
               "<a href='http://www.elixirstatus.com/'>Mag<a href='http://www.elixir-lang.org/'>ic"
             )
  end

  test "test_strip_links_with_a_tag_in_href" do
    assert "FrrFox" ==
             basic_html_sanitize("<href onlclick='steal()'>FrrFox</a></href>")
  end

  test "normal scrubbing does only allow certain tags and attributes" do
    input = "<span data-foo=\"bar\">foo</span>"
    expected = "<span>foo</span>"
    assert expected == basic_html_sanitize(input)
  end

  test "strips not allowed attributes" do
    input = "start <a title=\"1\" onclick=\"foo\">foo <bad>bar</bad> baz</a> end"

    expected = "start <a title=\"1\">foo bar baz</a> end"
    assert expected == basic_html_sanitize(input)
  end

  test "sanitize_script" do
    assert "a b cblah blah blahd e f" ==
             basic_html_sanitize(
               "a b c<script language=\"Javascript\">blah blah blah</script>d e f"
             )
  end

  @tag href_scrubbing: true
  test "sanitize_js_handlers" do
    input =
      ~s(onthis="do that" <a href="#" onclick="hello" name="foo" onbogus="remove me">hello</a>)

    assert ~s(onthis=&quot;do that&quot; <a href="#" name="foo">hello</a>) ==
             basic_html_sanitize(input)
  end

  test "sanitize_javascript_href" do
    raw =
      ~s(href="javascript:bang" <a href="javascript:bang" name="hello">foo</a>, <span href="javascript:bang">bar</span>)

    assert ~s(href=&quot;javascript:bang&quot; <a name="hello">foo</a>, <span>bar</span>) ==
             basic_html_sanitize(raw)
  end

  test "sanitize_image_src" do
    raw =
      ~s(src="javascript:bang" <img src="javascript:bang" width="5">foo</img>, <span src="javascript:bang">bar</span>)

    assert "src=&quot;javascript:bang&quot; <img width=\"5\"/>foo, <span>bar</span>" ==
             basic_html_sanitize(raw)
  end

  @tag href_scrubbing: true
  test "should only allow http/https protocols" do
    assert "<a href=\"foo\">baz</a>" ==
             basic_html_sanitize(~s(<a href="foo" onclick="bar"><script>baz</script></a>))

    assert "<a href=\"http://example.com\">baz</a>" ==
             basic_html_sanitize(
               ~s(<a href="http://example.com" onclick="bar"><script>baz</script></a>)
             )

    assert "<a href=\"https://example.com\">baz</a>" ==
             basic_html_sanitize(
               ~s(<a href="https://example.com" onclick="bar"><script>baz</script></a>)
             )
  end

  # test "video_poster_sanitization" do
  #  assert ~s(<video src="videofile.ogg" autoplay  poster="posterimage.jpg"></video>) == ~s(<video src="videofile.ogg" poster="posterimage.jpg"></video>)
  #  assert ~s(<video src="videofile.ogg"></video>) == basic_html_sanitize("<video src=\"videofile.ogg\" poster=javascript:alert(1)></video>")
  # end

  test "strips not allowed tags " do
    input = "<form><u></u></form>"
    expected = "<u></u>"
    assert expected == basic_html_sanitize(input)
  end

  test "strips not allowed attributes " do
    input = "<a foo=\"hello\" bar=\"world\"></a>"
    expected = "<a></a>"
    assert expected == basic_html_sanitize(input)
  end

  @image_src_hacks [
    "<IMG SRC=\"javascript:alert('XSS');\">",
    "<IMG SRC=javascript:alert('XSS')>",
    "<IMG SRC=JaVaScRiPt:alert('XSS')>",
    "<IMG SRC=javascript:alert(&quot;XSS&quot;)>",
    "<IMG SRC=javascript:alert(String.fromCharCode(88,83,83))>"
  ]

  test "strips malicious protocol hacks from img src attribute" do
    expected = "<img/>"

    Enum.each(@image_src_hacks, fn x ->
      assert expected == basic_html_sanitize(x)
    end)
  end

  test "strips script tag" do
    input = "<SCRIPT\nSRC=http://ha.ckers.org/xss.js></SCRIPT>"
    expected = ""
    assert expected == basic_html_sanitize(input)
  end

  test "strips xss image hack with uppercase tags" do
    input = "<IMG \"\"\"><SCRIPT>alert(\"XSS\")</SCRIPT>\">"
    expected = "<img/>alert(&quot;XSS&quot;)&quot;&gt;"
    assert expected == basic_html_sanitize(input)
  end

  test "should_sanitize_tag_broken_up_by_null" do
    assert "alert(&quot;XSS&quot;)" ==
             basic_html_sanitize("<SCR\0IPT>alert(\"XSS\")</SCR\0IPT>")
  end

  test "should_sanitize_invalid_script_tag" do
    input = "<SCRIPT/XSS SRC=\"http://ha.ckers.org/xss.js\"></SCRIPT>"
    assert "" == basic_html_sanitize(input)
  end

  test "sanitize half open scripts" do
    input = "<IMG SRC=\"javascript:alert('XSS')\""
    assert "" == basic_html_sanitize(input)
  end

  test "should_sanitize_within attributes" do
    input = "<span title=\"&#39;&gt;&lt;script&gt;alert()&lt;/script&gt;\">blah</span>"

    assert "<span>blah</span>" == basic_html_sanitize(input)
  end

  test "should_sanitize_invalid_tag_names" do
  end

  test "should_sanitize_non_alpha_and_non_digit_characters_in_tags" do
    assert "<a>foo</a>" ==
             basic_html_sanitize("<a onclick!@#$%^&*='alert(\"XSS\")'>foo</a>")
  end

  test "should_sanitize_invalid_tag_names_in_single_tags" do
    assert "<img/>" ==
             basic_html_sanitize("<img/src=\"javascript:alert('XSS')\"/>")
  end

  test "should_sanitize_img_dynsrc_lowsrc" do
    assert "<img/>" ==
             basic_html_sanitize("<img lowsrc=\"javascript:alert('XSS')\" />")
  end

  test "should_sanitize_img_vbscript" do
    assert "<img/>" ==
             basic_html_sanitize("<img src='vbscript:msgbox(\"XSS\")' />")
  end

  test "should_not_mangle_urls_with_ampersand" do
    input = "<a href=\"http://www.domain.com?var1=1&amp;var2=2\">my link</a>"
    assert input == basic_html_sanitize(input)
  end

  test "should_not_crash_on_invalid_schema_formatting_2" do
    input = "<a href=\"ftp://www.domain.com/http%3A//\">text here</a>"
    assert "<a>text here</a>" == basic_html_sanitize(input)
  end

  test "should_sanitize_neverending_attribute" do
    assert "" == basic_html_sanitize("<span class=\"\\")
  end

  # test "this affects only NS4, but we're on a roll, right?" do
  #  input = "<div size=\"&{alert('XSS')}\">foo</div>"
  #  expected = "<div>foo</div>"
  #  assert expected == basic_html_sanitize(input)
  # end

  test "does not strip the mailto URI scheme" do
    input = ~s(<a href="mailto:someone@yoursite.com">Email Us</a>)
    expected = ~s(<a href="mailto:someone@yoursite.com">Email Us</a>)
    assert expected == basic_html_sanitize(input)
  end
end
