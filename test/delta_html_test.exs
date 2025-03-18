defmodule DeltaHtmlTest do
  use ExUnit.Case, async: true

  import DeltaHtml

  test "empty input" do
    assert to_html([%{"insert" => "\n"}]) == "<p><br/></p>"
  end

  test "single word" do
    assert to_html([%{"insert" => "word\n"}]) == "<p>word</p>"
  end

  test "preserve whitespace" do
    assert to_html([%{"insert" => "This    has    multiple\tspaces\n"}], preserve_whitespace: true) ==
             "<div style=\"white-space: pre-wrap;\"><p>This    has    multiple\tspaces</p></div>"
  end

  test "heading" do
    assert to_html([
             %{"insert" => "Heading"},
             %{"attributes" => %{"header" => 1}, "insert" => "\n"}
           ]) ==
             "<h1>Heading</h1>"
  end

  test "bold" do
    assert to_html([
             %{"attributes" => %{"bold" => true}, "insert" => "bold"},
             %{"insert" => "\n"}
           ]) ==
             "<p><strong>bold</strong></p>"
  end

  test "italic" do
    assert to_html([
             %{"attributes" => %{"italic" => true}, "insert" => "italic"},
             %{"insert" => "\n"}
           ]) ==
             "<p><em>italic</em></p>"
  end

  test "underline" do
    assert to_html([
             %{"attributes" => %{"underline" => true}, "insert" => "underline"},
             %{"insert" => "\n"}
           ]) ==
             "<p><u>underline</u></p>"
  end

  test "underlined header" do
    assert to_html([
             %{"attributes" => %{"underline" => true}, "insert" => "Header"},
             %{"attributes" => %{"header" => 1}, "insert" => "\n"}
           ]) ==
             "<h1><u>Header</u></h1>"
  end

  test "multiple inline formattings" do
    assert to_html([
             %{
               "attributes" => %{"underline" => true, "italic" => true, "bold" => true},
               "insert" => "multiple"
             },
             %{"insert" => "\n"}
           ]) ==
             "<p><u><em><strong>multiple</strong></em></u></p>"
  end

  test "consecutive inline formattings" do
    assert to_html([
             %{"insert" => "a"},
             %{"attributes" => %{"bold" => true}, "insert" => "b"},
             %{"insert" => "c\n"}
           ]) ==
             "<p>a<strong>b</strong>c</p>"
  end

  test "link" do
    assert to_html([
             %{"attributes" => %{"link" => "https://example.com"}, "insert" => "link"},
             %{"insert" => "\n"}
           ]) ==
             ~s(<p><a href="https://example.com" target="_blank">link</a></p>)
  end

  test "link sanitization - allowed protocols" do
    assert to_html([
             %{"attributes" => %{"link" => "https://example.com"}, "insert" => "secure"},
             %{"insert" => "\n"}
           ]) ==
             ~s(<p><a href="https://example.com" target="_blank">secure</a></p>)

    assert to_html([
             %{"attributes" => %{"link" => "http://example.com"}, "insert" => "insecure"},
             %{"insert" => "\n"}
           ]) ==
             ~s(<p><a href="http://example.com" target="_blank">insecure</a></p>)

    assert to_html([
             %{"attributes" => %{"link" => "mailto:user@example.com"}, "insert" => "email"},
             %{"insert" => "\n"}
           ]) ==
             ~s(<p><a href="mailto:user@example.com" target="_blank">email</a></p>)
  end

  test "link sanitization - blocked protocols" do
    assert to_html([
             %{"attributes" => %{"link" => "javascript:alert(1)"}, "insert" => "malicious"},
             %{"insert" => "\n"}
           ]) ==
             "<p>malicious</p>"

    assert to_html([
             %{
               "attributes" => %{"link" => "mailto://foo@bar.com?body=<script>alert('Powned')</script>"},
               "insert" => "malicious"
             },
             %{"insert" => "\n"}
           ]) ==
             "<p>malicious</p>"

    assert to_html([
             %{"attributes" => %{"link" => "data:text/html,<script>alert(1)</script>"}, "insert" => "malicious"},
             %{"insert" => "\n"}
           ]) ==
             "<p>malicious</p>"

    assert to_html([
             %{"attributes" => %{"link" => "data:text/html,<script>alert(1)</script>"}, "insert" => "malicious"},
             %{"insert" => "\n"}
           ]) ==
             "<p>malicious</p>"
  end

  test "link sanitization - malformed URLs" do
    assert to_html([
             %{"attributes" => %{"link" => "not-a-url"}, "insert" => "text"},
             %{"insert" => "\n"}
           ]) ==
             "<p>text</p>"

    assert to_html([
             %{"attributes" => %{"link" => ""}, "insert" => "text"},
             %{"insert" => "\n"}
           ]) ==
             "<p>text</p>"
  end

  test "numbered list" do
    assert to_html([
             %{"insert" => "1"},
             %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "2"},
             %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"}
           ]) ==
             "<ol><li>1</li><li>2</li></ol>"
  end

  test "numbered list with indent" do
    assert to_html([
             %{"insert" => "1"},
             %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "a"},
             %{"attributes" => %{"indent" => 1, "list" => "ordered"}, "insert" => "\n"}
           ]) ==
             "<ol><li>1</li><ol><li>a</li></ol></ol>"
  end

  test "numbered list and bullet list" do
    assert to_html([
             %{"insert" => "1"},
             %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "x"},
             %{"attributes" => %{"list" => "bullet"}, "insert" => "\n"}
           ]) ==
             "<ol><li>1</li></ol><ul><li>x</li></ul>"
  end

  test "deeply nested lists" do
    assert to_html([
             %{"insert" => "b1"},
             %{"attributes" => %{"list" => "bullet"}, "insert" => "\n"},
             %{"insert" => "b2"},
             %{"attributes" => %{"list" => "bullet"}, "insert" => "\n"},
             %{"insert" => "b2.1"},
             %{"attributes" => %{"indent" => 1, "list" => "bullet"}, "insert" => "\n"},
             %{"insert" => "b2.1.1"},
             %{"attributes" => %{"indent" => 2, "list" => "bullet"}, "insert" => "\n"},
             %{"insert" => "n1.1"},
             %{"attributes" => %{"indent" => 1, "list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "n1"},
             %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "n2"},
             %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "n2.1.1"},
             %{"attributes" => %{"indent" => 2, "list" => "ordered"}, "insert" => "\n"}
           ]) ==
             "<ul><li>b1</li><li>b2</li><ul><li>b2.1</li><ul><li>b2.1.1</li></ul></ul></ul><ol><ol><li>n1.1</li></ol><li>n1</li><li>n2</li><ol><ol><li>n2.1.1</li></ol></ol></ol>"
  end

  test "placeholder" do
    assert to_html([
             %{"attributes" => %{"bold" => true}, "insert" => "Dear "},
             %{
               "attributes" => %{"bold" => true},
               "insert" => %{
                 "mention" => %{
                   "index" => "0",
                   "denotationChar" => "+",
                   "id" => "first_name",
                   "value" => "First_name"
                 }
               }
             },
             %{"attributes" => %{"bold" => true}, "insert" => ","},
             %{"insert" => "\nthank you.\n"}
           ]) ==
             "<p><strong>Dear </strong><strong>+first_name</strong><strong>,</strong></p><p>thank you.</p>"
  end

  test "color" do
    assert to_html([
             %{"attributes" => %{"color" => "#ff0000"}, "insert" => "red text"},
             %{"insert" => "\n"}
           ]) ==
             ~s(<p><span style="color: #ff0000;">red text</span></p>)
  end

  test "background color" do
    assert to_html([
             %{"attributes" => %{"background" => "#ffff00"}, "insert" => "highlighted text"},
             %{"insert" => "\n"}
           ]) ==
             ~s(<p><span style="background-color: #ffff00;">highlighted text</span></p>)
  end

  test "serif font" do
    assert to_html([
             %{"attributes" => %{"font" => "serif"}, "insert" => "serif text"},
             %{"insert" => "\n"}
           ]) ==
             ~s(<p><span style="font-family: serif;">serif text</span></p>)
  end

  test "monospace font" do
    assert to_html([
             %{"attributes" => %{"font" => "monospace"}, "insert" => "monospace text"},
             %{"insert" => "\n"}
           ]) ==
             ~s(<p><span style="font-family: monospace;">monospace text</span></p>)
  end

  test "unsupported font is ignored" do
    assert to_html([
             %{"attributes" => %{"font" => "Arial"}, "insert" => "Arial text"},
             %{"insert" => "\n"}
           ]) ==
             "<p>Arial text</p>"
  end

  test "small size" do
    assert to_html([
             %{"attributes" => %{"size" => "small"}, "insert" => "small text"},
             %{"insert" => "\n"}
           ]) ==
             ~s(<p><span style="font-size: 0.75em;">small text</span></p>)
  end

  test "large size" do
    assert to_html([
             %{"attributes" => %{"size" => "large"}, "insert" => "large text"},
             %{"insert" => "\n"}
           ]) ==
             ~s(<p><span style="font-size: 1.5em;">large text</span></p>)
  end

  test "huge size" do
    assert to_html([
             %{"attributes" => %{"size" => "huge"}, "insert" => "huge text"},
             %{"insert" => "\n"}
           ]) ==
             ~s(<p><span style="font-size: 2.5em;">huge text</span></p>)
  end

  test "indent with newlines" do
    assert to_html([
             %{"insert" => "zero\none"},
             %{"attributes" => %{"indent" => 1}, "insert" => "\n"},
             %{"insert" => "two"},
             %{"attributes" => %{"indent" => 2}, "insert" => "\n"}
           ]) ==
             ~s(<p>zero</p><p style="padding-left: 2em;">one</p><p style="padding-left: 4em;">two</p>)
  end

  test "unsupported size is ignored" do
    assert to_html([
             %{"attributes" => %{"size" => "medium"}, "insert" => "medium text"},
             %{"insert" => "\n"}
           ]) ==
             "<p>medium text</p>"
  end

  test "superscript" do
    assert to_html([
             %{"insert" => "x"},
             %{"attributes" => %{"script" => "super"}, "insert" => "2"},
             %{"insert" => "\n"}
           ]) ==
             "<p>x<sup>2</sup></p>"
  end

  test "subscript" do
    assert to_html([
             %{"insert" => "H"},
             %{"attributes" => %{"script" => "sub"}, "insert" => "2"},
             %{"insert" => "O\n"}
           ]) ==
             "<p>H<sub>2</sub>O</p>"
  end

  test "unsupported script value is ignored" do
    assert to_html([
             %{"attributes" => %{"script" => "invalid"}, "insert" => "text"},
             %{"insert" => "\n"}
           ]) ==
             "<p>text</p>"
  end

  test "inline code" do
    assert to_html([
             %{"insert" => "This is "},
             %{"attributes" => %{"code" => true}, "insert" => "inline code"},
             %{"insert" => ".\n"}
           ]) ==
             "<p>This is <code>inline code</code>.</p>"
  end

  test "blockquote" do
    assert to_html([
             %{"insert" => "This is a blockquote"},
             %{"attributes" => %{"blockquote" => true}, "insert" => "\n"}
           ]) ==
             "<blockquote>This is a blockquote</blockquote>"
  end

  test "text alignment - center" do
    assert to_html([
             %{"insert" => "Centered text"},
             %{"attributes" => %{"align" => "center"}, "insert" => "\n"}
           ]) ==
             ~s(<p style="text-align: center;">Centered text</p>)
  end

  test "text alignment - right" do
    assert to_html([
             %{"insert" => "Right aligned text"},
             %{"attributes" => %{"align" => "right"}, "insert" => "\n"}
           ]) ==
             ~s(<p style="text-align: right;">Right aligned text</p>)
  end

  test "text alignment - multiple blocks" do
    assert to_html([
             %{"insert" => "left\ncenter"},
             %{"attributes" => %{"align" => "center"}, "insert" => "\n"},
             %{"insert" => "right"},
             %{"attributes" => %{"align" => "right"}, "insert" => "\n"}
           ]) ==
             ~s(<p>left</p><p style="text-align: center;">center</p><p style="text-align: right;">right</p>)
  end

  test "mention with size and indent" do
    assert to_html([
             %{
               "attributes" => %{"size" => "large"},
               "insert" => %{"mention" => %{"denotationChar" => "+", "id" => "department"}}
             },
             %{"attributes" => %{"indent" => 1}, "insert" => "\n\n"}
           ]) ==
             ~s(<p style="padding-left: 2em;"><span style="font-size: 1.5em;">+department</span></p><p style="padding-left: 2em;"></p>)
  end
end
